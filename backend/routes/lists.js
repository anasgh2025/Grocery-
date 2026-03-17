'use strict';

const express = require('express');
const router = express.Router();
const listsController = require('../controllers/listsController');
const { requireAuth } = require('../middleware/auth');

/**
 * Optional auth middleware — attaches req.user if a valid Bearer token is
 * present, but does NOT reject the request if no token is provided.
 * Used on GET /lists so unauthenticated (legacy) callers still work.
 */
const optionalAuth = (req, res, next) => {
  const header = req.headers['authorization'] || '';
  if (!header.startsWith('Bearer ')) return next();
  requireAuth(req, res, next);
};

// ── Invite routes ──────────────────────────────────────────────────────────
// Public: preview an invite (no auth needed — user may not be logged in yet)
router.get('/invite/:token', listsController.getInvitePreview);

// Authenticated: generate, accept, reject
router.post('/:id/invite', requireAuth, listsController.generateInviteLink);
router.post('/invite/:token/accept', requireAuth, listsController.acceptInvite);
router.post('/invite/:token/reject', requireAuth, listsController.rejectInvite);

// ── List CRUD ──────────────────────────────────────────────────────────────
router.get('/', optionalAuth, listsController.getAllLists);
router.get('/:id', listsController.getListById);
router.post('/', optionalAuth, listsController.createList);
router.put('/:id', listsController.updateList);
router.delete('/:id', listsController.deleteList);

// ── Item routes ────────────────────────────────────────────────────────────
router.get('/:id/items', listsController.getListItems);
router.post('/:id/items', listsController.addListItem);
router.put('/:id/items/:itemId', listsController.updateListItem);
router.delete('/:id/items/:itemId', listsController.deleteListItem);

module.exports = router;
