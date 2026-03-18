// Switch to Mongo-backed store when available. The code imports the mongo-backed
// implementation `usersStore.mongodb.js` which exposes the same API as the
// previous sqlite-backed store (getAll, getById, findByEmail, create).
const usersStore = require('../data/usersStore.mongodb');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const nodemailer = require('nodemailer');

// JWT secret (use env var in production)
const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-me';

// Create a new user/profile (async)
const createUser = async (req, res) => {
  try {
    const { name, email, password } = req.body || {};
    const sEmail = typeof email === 'string' ? email.trim().toLowerCase() : '';
    const sName = typeof name === 'string' ? name.trim() : '';
    const sPassword = typeof password === 'string' ? password : '';

    if (!sEmail || !sPassword) {
      return res.status(400).json({ error: 'Bad Request', message: 'Missing required fields: email, password' });
    }

    // basic (permissive) email validation - allow common characters like '+' and longer TLDs
    // This keeps validation simple for development while rejecting obvious invalid values.
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(sEmail)) {
      return res.status(400).json({ error: 'Bad Request', message: 'Invalid email format' });
    }

    if (sPassword.length < 6) {
      return res.status(400).json({ error: 'Bad Request', message: 'Password must be at least 6 characters' });
    }

    // Check for existing user
    const existing = await usersStore.findByEmail(sEmail);
    if (existing) {
      return res.status(409).json({ error: 'Conflict', message: 'User with this email already exists' });
    }

    // Hash password
    const hashed = await bcrypt.hash(sPassword, 10);

    // Create user (store hashed password)
    const created = await usersStore.create({ name: sName, email: sEmail, password: hashed });
    res.status(201).json(created);
  } catch (err) {
    console.error('createUser error:', err);
    res.status(500).json({ error: 'Failed to create user', message: err.message });
  }
};

// (Optional) list users - for debugging only
const listUsers = async (req, res) => {
  try {
    const rows = await usersStore.getAll();
    const all = rows.map(u => ({ id: u.id, name: u.name, email: u.email }));
    res.json(all);
  } catch (err) {
    console.error('listUsers error:', err);
    res.status(500).json({ error: 'Failed to fetch users', message: err.message });
  }
};

// Login - verify password and return a JWT + user info
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body || {};
    const sEmail = typeof email === 'string' ? email.trim().toLowerCase() : '';
    const sPassword = typeof password === 'string' ? password : '';

    if (!sEmail || !sPassword) {
      return res.status(400).json({ error: 'Bad Request', message: 'Missing required fields: email, password' });
    }

    const user = await usersStore.findByEmail(sEmail);
    if (!user) {
      return res.status(401).json({ error: 'Unauthorized', message: 'Invalid email or password' });
    }

    const match = await bcrypt.compare(sPassword, user.password);
    if (!match) {
      return res.status(401).json({ error: 'Unauthorized', message: 'Invalid email or password' });
    }

    // Create JWT payload (minimal)
    const payload = { sub: user.id, email: user.email };
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });

    res.json({ token, user: { id: user.id, name: user.name, email: user.email } });
  } catch (err) {
    console.error('loginUser error:', err);
    res.status(500).json({ error: 'Failed to login', message: err.message });
  }
};

module.exports = { createUser, listUsers, loginUser, changePassword, deleteAccount, forgotPassword, resetPassword };

// Change the authenticated user's password
async function changePassword(req, res) {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });

    const { currentPassword, newPassword } = req.body || {};
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ error: 'Bad Request', message: 'currentPassword and newPassword are required' });
    }
    if (newPassword.length < 6) {
      return res.status(400).json({ error: 'Bad Request', message: 'New password must be at least 6 characters' });
    }

    const user = await usersStore.getById(userId);
    if (!user) return res.status(404).json({ error: 'Not Found' });

    // getById strips the password — fetch the full doc
    const fullUser = await usersStore.findByEmail(user.email);
    const match = await bcrypt.compare(currentPassword, fullUser.password);
    if (!match) return res.status(401).json({ error: 'Unauthorized', message: 'Current password is incorrect' });

    const hashed = await bcrypt.hash(newPassword, 10);
    await usersStore.updatePassword(userId, hashed);
    res.json({ message: 'Password updated successfully' });
  } catch (err) {
    console.error('changePassword error:', err);
    res.status(500).json({ error: 'Failed to change password', message: err.message });
  }
}

// Delete the authenticated user's account
async function deleteAccount(req, res) {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });
    await usersStore.deleteById(userId);
    res.json({ message: 'Account deleted successfully' });
  } catch (err) {
    console.error('deleteAccount error:', err);
    res.status(500).json({ error: 'Failed to delete account', message: err.message });
  }
}

// POST /users/forgot-password  { email }
async function forgotPassword(req, res) {
  try {
    const email = typeof req.body?.email === 'string' ? req.body.email.trim().toLowerCase() : '';
    // Always respond 200 so we don't leak whether the email exists
    if (!email) return res.json({ message: 'If that email is registered you will receive a reset link.' });

    const user = await usersStore.findByEmail(email);
    if (!user) return res.json({ message: 'If that email is registered you will receive a reset link.' });

    // Generate a secure token valid for 1 hour
    const token = crypto.randomBytes(32).toString('hex');
    const expiry = new Date(Date.now() + 60 * 60 * 1000);
    await usersStore.saveResetToken(email, token, expiry);

    // Build deep link that opens the app
    const appScheme = process.env.APP_SCHEME || 'grovia';
    const resetLink = `${appScheme}://reset-password?token=${token}`;

    // Always log the reset link so it works even without email configured
    console.log(`[forgotPassword] Reset link for ${email}: ${resetLink}`);

    // Try to send email — but don't fail the whole request if SMTP isn't configured
    if (process.env.EMAIL_USER && process.env.EMAIL_PASS) {
      try {
        const transporter = nodemailer.createTransport({
          host: process.env.EMAIL_HOST || 'smtp.gmail.com',
          port: parseInt(process.env.EMAIL_PORT || '587'),
          secure: false,
          auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASS,
          },
        });

        await transporter.sendMail({
          from: `"Grovia App" <${process.env.EMAIL_USER}>`,
          to: email,
          subject: 'Reset your Grovia password',
          html: `
            <div style="font-family:sans-serif;max-width:480px;margin:auto;padding:32px">
              <h2 style="color:#E53935">Reset your password</h2>
              <p>Hi ${user.name || 'there'},</p>
              <p>We received a request to reset the password for your Grovia account.</p>
              <p>Tap the button below on your phone to choose a new password. This link expires in <strong>1 hour</strong>.</p>
              <a href="${resetLink}"
                 style="display:inline-block;margin:24px 0;padding:14px 28px;background:#E53935;color:#fff;border-radius:10px;text-decoration:none;font-weight:bold;font-size:16px">
                Reset Password
              </a>
              <p style="color:#888;font-size:13px">If you didn't request this, you can safely ignore this email.</p>
            </div>
          `,
        });
        console.log(`[forgotPassword] Email sent to ${email}`);
      } catch (emailErr) {
        // Email failed — log it but still return success so the token is usable
        console.error('[forgotPassword] Email send failed:', emailErr.message);
      }
    } else {
      console.warn('[forgotPassword] EMAIL_USER/EMAIL_PASS not set — skipping email send.');
    }

    // In non-production, include the link in the response so developers can test without email
    const isDev = process.env.NODE_ENV !== 'production';
    res.json({
      message: 'If that email is registered you will receive a reset link.',
      ...(isDev && { devResetLink: resetLink }),
    });
  } catch (err) {
    console.error('forgotPassword error:', err);
    res.status(500).json({ error: 'Failed to send reset email', message: err.message });
  }
}

// POST /users/reset-password  { token, newPassword }
async function resetPassword(req, res) {
  try {
    const { token, newPassword } = req.body || {};
    if (!token || !newPassword) {
      return res.status(400).json({ error: 'Bad Request', message: 'token and newPassword are required' });
    }
    if (newPassword.length < 6) {
      return res.status(400).json({ error: 'Bad Request', message: 'Password must be at least 6 characters' });
    }

    const user = await usersStore.findByResetToken(token);
    if (!user) {
      return res.status(400).json({ error: 'Invalid', message: 'This reset link is invalid or has expired.' });
    }
    if (!user.resetTokenExpiry || new Date() > new Date(user.resetTokenExpiry)) {
      return res.status(400).json({ error: 'Expired', message: 'This reset link is invalid or has expired.' });
    }

    const hashed = await bcrypt.hash(newPassword, 10);
    await usersStore.updatePassword(user.id, hashed);
    await usersStore.clearResetToken(user.id);

    res.json({ message: 'Password reset successfully.' });
  } catch (err) {
    console.error('resetPassword error:', err);
    res.status(500).json({ error: 'Failed to reset password', message: err.message });
  }
}
