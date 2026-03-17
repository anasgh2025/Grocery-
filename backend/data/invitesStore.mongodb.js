'use strict';

const mongoose = require('mongoose');
const crypto = require('crypto');

const inviteSchema = new mongoose.Schema({
  token:     { type: String, required: true, unique: true, index: true },
  listId:    { type: String, required: true },
  listName:  { type: String, required: true },
  createdBy: { type: String, required: true },  // userId of the list owner
  createdByName: { type: String, default: '' }, // display name of inviter
  expiresAt: { type: Date, required: true },
  used:      { type: Boolean, default: false },
  acceptedBy: { type: String, default: null },  // userId who accepted
}, { timestamps: true });

const Invite = mongoose.models.Invite || mongoose.model('Invite', inviteSchema);

/**
 * Create a new invite token for a list.
 * @param {string} listId
 * @param {string} listName
 * @param {string} createdBy   - userId of the owner
 * @param {string} createdByName - display name of the owner
 */
const createInvite = async ({ listId, listName, createdBy, createdByName }) => {
  const token = crypto.randomBytes(20).toString('hex');
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
  const doc = await Invite.create({ token, listId, listName, createdBy, createdByName, expiresAt });
  return doc.toObject();
};

/**
 * Find an invite by token. Returns null if not found, expired, or already used.
 */
const findInvite = async (token) => {
  const doc = await Invite.findOne({ token, used: false, expiresAt: { $gt: new Date() } }).lean();
  return doc || null;
};

/**
 * Mark an invite as used by a specific user.
 */
const markUsed = async (token, acceptedBy) => {
  await Invite.updateOne({ token }, { $set: { used: true, acceptedBy } });
};

module.exports = { createInvite, findInvite, markUsed, Invite };
