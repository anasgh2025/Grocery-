const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const DB_FILE = path.join(__dirname, 'users.db');

// Open DB (creates file if missing)
const db = new sqlite3.Database(DB_FILE, (err) => {
  if (err) {
    console.error('Failed to open users database:', err.message);
    throw err;
  }
});

// Initialize schema
db.serialize(() => {
  db.run(
    `CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      created_at TEXT NOT NULL
    )`,
    (err) => {
      if (err) console.error('Failed to ensure users table:', err.message);
    }
  );
});

const run = (sql, params = []) =>
  new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) return reject(err);
      resolve({ lastID: this.lastID, changes: this.changes });
    });
  });

const get = (sql, params = []) =>
  new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) return reject(err);
      resolve(row);
    });
  });

const all = (sql, params = []) =>
  new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) return reject(err);
      resolve(rows);
    });
  });

const getAll = async () => {
  const rows = await all('SELECT id, name, email, created_at FROM users ORDER BY created_at DESC');
  return rows.map((r) => ({ ...r }));
};

const getById = async (id) => {
  const row = await get('SELECT id, name, email, created_at FROM users WHERE id = ?', [id]);
  return row || null;
};

const findByEmail = async (email) => {
  if (!email) return null;
  const row = await get('SELECT id, name, email, password, created_at FROM users WHERE lower(email) = lower(?)', [String(email)]);
  return row || null;
};

const create = async ({ name, email, password }) => {
  const id = uuidv4();
  const created_at = new Date().toISOString();
  await run('INSERT INTO users (id, name, email, password, created_at) VALUES (?, ?, ?, ?, ?)', [id, name || '', email || '', password || '', created_at]);
  return { id, name: name || '', email: email || '', created_at };
};

module.exports = { getAll, getById, findByEmail, create };
