const express = require('express');
const cors = require('cors');
require('dotenv').config();
// Build: 2026-02-25
const app = express();
const DEFAULT_PORT = 8081;
const PORT = process.env.PORT || DEFAULT_PORT;
const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});

server.on("error", (err) => {
  if (err.code === "EADDRINUSE") {
    console.error(`Port ${PORT} is already in use`);
    process.exit(1);
  } else {
    console.error(err);
  }
});
//
//


//
// Connect to MongoDB (accept full MONGODB_URI or build it from parts)
const mongoose = require('mongoose');

const buildMongoUri = () => {
  // Prefer an explicit MONGODB_URI
  if (process.env.MONGODB_URI && process.env.MONGODB_URI.trim() !== '') {
    let uri = process.env.MONGODB_URI.trim();

    // DigitalOcean App Platform injects a URI that defaults to the "admin"
    // database.  Rewrite it so the app uses "Grocery" instead.
    uri = uri.replace(/\/admin(\?|$)/, '/Grocery$1');

    return uri;
  }

  // Otherwise try to build from components (useful for CI / env injection)
  const user = process.env.DB_USER;
  const pass = process.env.DB_PASS;
  const host = process.env.DB_HOST || '127.0.0.1:27017';
  const name = process.env.DB_NAME || 'grocery_app';

  if (user && pass && host) {
    // If host looks like an SRV host (contains mongodb+srv) the caller should include it
    // We'll build an SRV-style URI if host starts with "mongodb+srv://" already.
    let hostUri = host;
    if (!hostUri.startsWith('mongodb')) {
      // assume SRV is desired for managed providers; user can provide full MONGODB_URI to override
      hostUri = `mongodb+srv://${host}`;
    }

    // Default to authSource=admin and TLS on managed providers; caller can append query params
    const defaultOptions = 'retryWrites=true&w=majority&authSource=admin&tls=true';
    return `${hostUri}/${encodeURIComponent(name)}?${defaultOptions}`
      .replace('mongodb+srv://', `mongodb+srv://${encodeURIComponent(user)}:${encodeURIComponent(pass)}@`)
      .replace('mongodb://', `mongodb://${encodeURIComponent(user)}:${encodeURIComponent(pass)}@`);
  }

  // fallback to localhost
  return 'mongodb://127.0.0.1:27017/grocery_app';
};

const MONGODB_URI = buildMongoUri();

const startServer = async () => {
  try {
    // Use modern mongoose connect options
    await mongoose.connect(MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log(`🔗 Connected to MongoDB: ${MONGODB_URI}`);

    // Seed default marketing cards if collection is empty
    const { seedDefaults: seedMarketing } = require('./data/marketingStore.mongodb');
    await seedMarketing();

    // Seed default categories if collection is empty
    const { seedDefaults: seedCategories } = require('./data/categoriesStore.mongodb');
    await seedCategories();
  } catch (err) {
    console.error('Failed to connect to MongoDB:');
    console.error(err && err.message ? err.message : String(err));

    // Give actionable hints for common issues
    console.error('\nCommon causes:');
    console.error('- Wrong username/password for the provided user.');
    console.error('- The user was created on a different auth DB (try adding &authSource=admin or &authSource=<yourAuthDb>).');
    console.error('- TLS/SSL is required by the provider (use SRV connection or add &tls=true).');
    console.error('- Your IP is not allowlisted by the cluster firewall.');
    console.error('- If using an SRV URI, ensure the full provider-provided connection string is used.');

    // Exit so the operator can notice and fix the connection string / network
    process.exit(1);
  }

    app.listen(PORT, () => {
    console.log(`🚀 Server is running on http://localhost:${PORT}`);
    console.log(`📝 API Documentation: http://localhost:${PORT}`);
    console.log(`❤️  Health Check: http://localhost:${PORT}/api/health`);
  });
};

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Routes
const listsRoutes = require('./routes/lists');
const marketingRoutes = require('./routes/marketing');
const usersRoutes = require('./routes/users');
const categoriesRoutes = require('./routes/categories');
app.use('/api/lists', listsRoutes);
app.use('/api/marketing', marketingRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/categories', categoriesRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  const mongoose = require('mongoose');
  const dbName = mongoose.connection.db ? mongoose.connection.db.databaseName : 'not connected';
  res.json({
    status: 'OK',
    message: 'Grocery App API is running',
    timestamp: new Date().toISOString(),
    database: dbName,
    uriDb: MONGODB_URI.replace(/\/\/[^@]+@/, '//****@'),
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Grocery App API',
    version: '1.0.0',
    endpoints: {
      health: '/api/health',
      lists: '/api/lists'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Cannot ${req.method} ${req.path}`
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message
  });
});

// Start server after connecting to MongoDB
startServer();

module.exports = app;
