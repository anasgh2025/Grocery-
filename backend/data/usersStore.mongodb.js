const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

// Define user schema
const userSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  name: { type: String, default: '' },
  email: { type: String, required: true, unique: true, index: true },
  password: { type: String, required: true },
  created_at: { type: Date, required: true },
});

// Ensure we use the 'users' collection
const User = mongoose.models.User || mongoose.model('User', userSchema, 'users');

const getAll = async () => {
  const rows = await User.find({}, { _id: 0, id: 1, name: 1, email: 1, created_at: 1 }).sort({ created_at: -1 }).lean();
  return rows.map((r) => ({ ...r, created_at: r.created_at instanceof Date ? r.created_at.toISOString() : r.created_at }));
};

const getById = async (id) => {
  const row = await User.findOne({ id }, { _id: 0, id: 1, name: 1, email: 1, created_at: 1 }).lean();
  if (!row) return null;
  return { ...row, created_at: row.created_at instanceof Date ? row.created_at.toISOString() : row.created_at };
};

const findByEmail = async (email) => {
  if (!email) return null;
  const s = String(email).trim().toLowerCase();
  const row = await User.findOne({ email: s }).lean();
  return row || null;
};

const create = async ({ name, email, password }) => {
  const id = uuidv4();
  const created_at = new Date();
  const doc = new User({ id, name: name || '', email: String(email).trim().toLowerCase(), password: password || '', created_at });
  await doc.save();
  return { id, name: name || '', email: String(email).trim().toLowerCase(), created_at: created_at.toISOString() };
};

const updatePassword = async (id, hashedPassword) => {
  await User.updateOne({ id }, { $set: { password: hashedPassword } });
};

const deleteById = async (id) => {
  await User.deleteOne({ id });
};

module.exports = { getAll, getById, findByEmail, create, updatePassword, deleteById, User };
