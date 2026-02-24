// Switch to Mongo-backed store when available. The code imports the mongo-backed
// implementation `usersStore.mongodb.js` which exposes the same API as the
// previous sqlite-backed store (getAll, getById, findByEmail, create).
const usersStore = require('../data/usersStore.mongodb');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

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

module.exports = { createUser, listUsers, loginUser };
