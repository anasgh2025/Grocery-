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

// ── Zoho SMTP transporter ─────────────────────────────────────────────────────
const transporter = nodemailer.createTransport({
  host: 'smtp.zoho.com',
  port: 465,
  secure: true, // SSL
  auth: {
    user: process.env.ZOHO_EMAIL,    // e.g. noreply@grovia.app
    pass: process.env.ZOHO_PASSWORD, // App-specific password from Zoho
  },
});

async function sendEmail({ to, subject, html }) {
  if (!process.env.ZOHO_EMAIL || !process.env.ZOHO_PASSWORD) {
    console.warn(`Email skipped for ${to}: missing ZOHO_EMAIL or ZOHO_PASSWORD`);
    return;
  }

  await transporter.sendMail({
    from: `"Grovia" <${process.env.ZOHO_EMAIL}>`,
    to,
    subject,
    html,
  });
}

async function sendWelcomeEmail({ email, name }) {
  const displayName = name?.trim() || 'there';

  await sendEmail({
    to: email,
    subject: 'Welcome to Grovia',
    html: `
      <div style="font-family:sans-serif;max-width:480px;margin:auto;padding:32px;line-height:1.5;">
        <h2 style="color:#E53935;margin-bottom:12px;">Welcome to Grovia, ${displayName}!</h2>
        <p>Your account is ready. You can now sign in and start organizing your grocery lists.</p>
        <p style="margin-top:20px;">What you can do next:</p>
        <ul style="padding-left:20px;">
          <li>Create and manage grocery lists</li>
          <li>Share lists with family members</li>
          <li>Keep everything synced across devices</li>
        </ul>
        <p style="margin-top:24px;">Thanks for joining Grovia.</p>
      </div>
    `,
  });
}

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

    try {
      await sendWelcomeEmail({ email: sEmail, name: sName });
    } catch (mailErr) {
      console.error('sendWelcomeEmail error:', mailErr);
    }

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

// POST /api/users/forgot-password  (public)
async function forgotPassword(req, res) {
  try {
    const { email } = req.body || {};
    const sEmail = typeof email === 'string' ? email.trim().toLowerCase() : '';
    if (!sEmail) {
      return res.status(400).json({ error: 'Bad Request', message: 'email is required' });
    }

    // Always respond with 200 to avoid user enumeration
    const user = await usersStore.findByEmail(sEmail);
    if (!user) {
      return res.status(200).json({ message: 'If that email is registered, a reset link has been sent.' });
    }

    const token = crypto.randomBytes(32).toString('hex');
    const expires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    await usersStore.setResetToken(sEmail, token, expires);

    const resetUrl = `https://coral-app-qjq4a.ondigitalocean.app/a/reset-password/${token}`;

    await sendEmail({
      to: sEmail,
      subject: 'Reset your Grovia password',
      html: `
        <div style="font-family:sans-serif;max-width:480px;margin:auto;padding:32px;">
          <h2 style="color:#E53935;">Reset your password</h2>
          <p>We received a request to reset the password for your Grovia account.</p>
          <p>Click the button below to choose a new password. This link expires in <strong>1 hour</strong>.</p>
          <a href="${resetUrl}"
             style="display:inline-block;margin:24px 0;padding:14px 28px;background:#E53935;color:#fff;
                    border-radius:8px;text-decoration:none;font-weight:600;">
            Reset Password
          </a>
          <p style="color:#888;font-size:13px;">If you did not request this, you can safely ignore this email.</p>
        </div>
      `,
    });

    res.status(200).json({ message: 'If that email is registered, a reset link has been sent.' });
  } catch (err) {
    console.error('forgotPassword error:', err);
    res.status(500).json({ error: 'Failed to send reset email', message: err.message });
  }
}

// POST /api/users/reset-password  (public)
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
      return res.status(400).json({ error: 'Invalid or expired reset token' });
    }

    const hashed = await bcrypt.hash(newPassword, 10);
    await usersStore.updatePassword(user.id, hashed);
    await usersStore.clearResetToken(user.id);

    res.status(200).json({ message: 'Password has been reset successfully.' });
  } catch (err) {
    console.error('resetPassword error:', err);
    res.status(500).json({ error: 'Failed to reset password', message: err.message });
  }
}
