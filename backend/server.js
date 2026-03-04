// backend/server.js
"use strict";

const express = require("express");
const cors = require("cors");
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


// ---- Mount lists routes ----
const listsRoutes = require("./routes/lists");
app.use("/api/lists", listsRoutes);

// ---- 404 handler ----
app.use((req, res) => {
  res.status(404).json({ error: "Not Found" });
});

// ---- Error handler ----
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);
  res.status(500).json({ error: "Internal Server Error" });
});

// ---- Port & Server ----
// DigitalOcean App Platform should ALWAYS provide process.env.PORT
const PORT = process.env.PORT;

if (!PORT) {
  console.error("❌ PORT environment variable not set. This app must run with a PORT provided by the platform.");
  process.exit(1);
}

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

  // Force exit if it hangs
  setTimeout(() => {
    console.error("❌ Force exiting after timeout.");
    process.exit(1);
  }, 10_000).unref();
}

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));