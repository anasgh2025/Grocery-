// backend/server.js
"use strict";

const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");
require("dotenv").config();

const app = express();

// ---- Middleware ----
app.use(cors());
app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true }));

// ---- Health check (useful for DigitalOcean) ----
app.get("/health", (req, res) => {
  res.status(200).json({ ok: true, service: "grocery-backend" });
});

// ---- Mount routes ----
const listsRoutes = require("./routes/lists");
app.use("/api/lists", listsRoutes);

const categoriesRoutes = require("./routes/categories");
app.use("/api/categories", categoriesRoutes);

const marketingRoutes = require("./routes/marketing");
app.use("/api/marketing", marketingRoutes);
const usersRoutes = require("./routes/users");
app.use("/api/users", usersRoutes);

// ---- Invite deep-link redirect ----
// When a user taps the invite link on a phone, redirect to the custom scheme
// so the OS opens the Grovia app (or the app store if not installed).
app.get("/invite/:token", (req, res) => {
  const { token } = req.params;
  // Universal/deep-link: grovia://invite/<token>
  const deepLink = `grovia://invite/${token}`;
  res.send(`<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta http-equiv="refresh" content="0; url=${deepLink}"/>
  <title>Opening Grovia…</title>
  <script>window.location.href = "${deepLink}";</script>
</head>
<body style="font-family:sans-serif;text-align:center;padding-top:80px;">
  <p>Opening Grovia…</p>
  <p><a href="${deepLink}">Tap here if the app does not open</a></p>
</body>
</html>`);
});

// ---- 404 handler (keep AFTER all routes) ----
app.use((req, res) => {
  res.status(404).json({ error: "Not Found" });
});

// ---- Error handler ----
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);
  res.status(500).json({ error: "Internal Server Error" });
});

// ---- Config ----
// DigitalOcean App Platform should ALWAYS provide process.env.PORT
const PORT = process.env.PORT;
if (!PORT) {
  console.error(
    "❌ PORT environment variable not set. This app must run with a PORT provided by the platform."
  );
  process.exit(1);
}

const MONGODB_URI = process.env.MONGODB_URI;
if (!MONGODB_URI) {
  console.error("❌ MONGODB_URI environment variable not set.");
  process.exit(1);
}

// ---- DB Connect + Start Server ----

const { seedDefaults } = require("./data/categoriesStore.mongodb");

async function start() {
  try {
    // Fail fast with clearer errors than buffering timeouts
    mongoose.set("bufferCommands", false);

    await mongoose.connect(MONGODB_URI, {
      serverSelectionTimeoutMS: 10000,
      // tls: true, // optional; your URI already has tls=true
    });

    console.log("✅ MongoDB connected");

    // Seed categories if needed
    await seedDefaults();

    const server = app.listen(Number(PORT), "0.0.0.0", () => {
      console.log(`✅ Server running on port ${PORT}`);
    });

    // ---- Handle port-in-use and other listen errors ----
    server.on("error", (err) => {
      if (err && err.code === "EADDRINUSE") {
        console.error(`❌ Port ${PORT} is already in use`);
        process.exit(1);
      }
      console.error("❌ Server error:", err);
      process.exit(1);
    });

    // ---- Graceful shutdown (recommended for containers) ----
    function shutdown(signal) {
      console.log(`\n${signal} received. Shutting down gracefully...`);
      server.close(() => {
        console.log("✅ HTTP server closed.");
        process.exit(0);
      });

      // Close Mongo connection too
      mongoose.connection
        .close(false)
        .then(() => console.log("✅ MongoDB connection closed."))
        .catch((e) => console.error("❌ Error closing MongoDB connection:", e));

      // Force exit if it hangs
      setTimeout(() => {
        console.error("❌ Force exiting after timeout.");
        process.exit(1);
      }, 10_000).unref();
    }

    process.on("SIGTERM", () => shutdown("SIGTERM"));
    process.on("SIGINT", () => shutdown("SIGINT"));
  } catch (err) {
    console.error("❌ Startup failed:", err);
    process.exit(1);
  }
}

start();