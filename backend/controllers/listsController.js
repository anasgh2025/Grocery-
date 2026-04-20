// POST /api/lists/migrate-guest-lists
// Body: { guestId: string }
// Requires auth (user must be logged in)
const migrateGuestLists = async (req, res) => {
  try {
    const userId = req.user && req.user.id;
    const { guestId } = req.body;
    if (!userId || !guestId) {
      return res.status(400).json({ error: 'Missing userId or guestId' });
    }
    const modified = await store.migrateGuestListsToUser(guestId, userId);
    res.json({ migrated: modified });
  } catch (error) {
    res.status(500).json({ error: 'Failed to migrate guest lists', message: error.message });
  }
};
'use strict';

const { v4: uuidv4 } = require('uuid');
const store = require('../data/listsStore.mongodb');
const invitesStore = require('../data/invitesStore.mongodb');
const usersStore = require('../data/usersStore.mongodb');

// ── Invite handlers ────────────────────────────────────────────────────────────

/**
 * POST /api/lists/:id/invite  (requires auth)
 * Generates a persistent invite token stored in MongoDB.
 */
const generateInviteLink = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const list = await store.getById(id);
    if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });

    // Only the owner (or a member) can invite others
    if (list.ownerId && list.ownerId !== userId && !list.sharedWith.includes(userId)) {
      return res.status(403).json({ error: 'Forbidden', message: 'You do not have access to this list' });
    }

    const inviter = await usersStore.getById(userId);
    const invite = await invitesStore.createInvite({
      listId: id,
      listName: list.name,
      createdBy: userId,
      createdByName: inviter ? inviter.name || inviter.email : '',
    });

    // Deep-link URL the Flutter app will handle
    const inviteUrl = `https://coral-app-qjq4a.ondigitalocean.app/a/invite/${invite.token}`;
    res.json({ inviteUrl, token: invite.token });
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate invite link', message: error.message });
  }
};

/**
 * GET /api/lists/invite/:token  (public — no auth)
 * Returns list preview so Flutter can show the accept/reject screen.
 */
const getInvitePreview = async (req, res) => {
  try {
    const { token } = req.params;
    const invite = await invitesStore.findInvite(token);
    if (!invite) {
      return res.status(404).json({ error: 'Invalid or expired invite link' });
    }
    const list = await store.getById(invite.listId);
    res.json({
      listId: invite.listId,
      listName: invite.listName,
      invitedBy: invite.createdByName,
      itemCount: list ? (list.listItems || []).length : 0,
      token,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch invite preview', message: error.message });
  }
};

/**
 * POST /api/lists/invite/:token/accept  (requires auth)
 * Marks token used and adds the authenticated user to sharedWith.
 */
const acceptInvite = async (req, res) => {
  try {
    const { token } = req.params;
    const userId = req.user.id;

    const invite = await invitesStore.findInvite(token);
    if (!invite) {
      return res.status(404).json({ error: 'Invalid or expired invite link' });
    }

    // Don't let the owner accept their own invite
    if (invite.createdBy === userId) {
      return res.status(400).json({ error: 'You cannot accept your own invite' });
    }

    await store.addSharedUser(invite.listId, userId);
    await invitesStore.markUsed(token, userId);

    res.json({ success: true, listId: invite.listId });
  } catch (error) {
    res.status(500).json({ error: 'Failed to accept invite', message: error.message });
  }
};

/**
 * POST /api/lists/invite/:token/reject  (requires auth)
 * Simply marks the token as used without adding to sharedWith.
 */
const rejectInvite = async (req, res) => {
  try {
    const { token } = req.params;
    const invite = await invitesStore.findInvite(token);
    if (!invite) {
      return res.status(404).json({ error: 'Invalid or expired invite link' });
    }
    await invitesStore.markUsed(token, req.user.id);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Failed to reject invite', message: error.message });
  }
};

// Get all lists
const getAllLists = async (req, res) => {
  try {
    // If the caller has a JWT (attached by optional auth), filter to their lists.
    const userId = req.user ? req.user.id : null;
    // For guests, get guestId from header
    const guestId = req.headers['x-guest-id'] || null;
    const lists = await store.getAllForUser(userId, guestId);
    res.json(lists);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch lists',
      message: error.message
    });
  }
};

// Get single list by ID
const getListById = async (req, res) => {
  try {
    const { id } = req.params;
    const list = await store.getById(id);
    
    if (!list) {
      return res.status(404).json({
        error: 'Not Found',
        message: `List with ID ${id} not found`
      });
    }
    
    res.json(list);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch list',
      message: error.message
    });
  }
};

// Create new list
const createList = async (req, res) => {
  try {
  let { name, items, progress, time, icon, priority, category } = req.body;
  if (!time) time = '';
    
    // Validate required fields (time is now optional)
    if (!name || items === undefined || progress === undefined || !icon) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Missing required fields: name, items, progress, icon'
      });
    }

    // Check for duplicate list name (case-insensitive) within this user's lists only
    const userId = req.user ? req.user.id : null;
    const allLists = await store.getAllForUser(userId);
    const duplicate = allLists.find(l => l.name.toLowerCase() === name.trim().toLowerCase());
    if (duplicate) {
      return res.status(409).json({
        error: 'Conflict',
        message: `A list named "${name.trim()}" already exists`
      });
    }
    
    // Validate progress is between 0 and 1
    if (progress < 0 || progress > 1) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Progress must be between 0 and 1'
      });
    }
    
    // Create new list with generated ID
    const newList = {
      id: uuidv4(),
      name,
      items,
      progress,
      time,
      icon,
      category: category !== undefined ? category : null,
      priority: priority !== undefined ? priority : 0,
      ownerId: req.user ? req.user.id : null,
      guestId: !req.user && req.body.guestId ? req.body.guestId : null,
    };
    
    const createdList = await store.create(newList);
    res.status(201).json(createdList);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to create list',
      message: error.message
    });
  }
};

// Update existing list
const updateList = async (req, res) => {
  try {
  const { id } = req.params;
  const { name, items, progress, time, icon, priority, category } = req.body;
    
    // Check if list exists
    const existingList = await store.getById(id);
    if (!existingList) {
      return res.status(404).json({
        error: 'Not Found',
        message: `List with ID ${id} not found`
      });
    }
    
    // Validate progress if provided
    if (progress !== undefined && (progress < 0 || progress > 1)) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Progress must be between 0 and 1'
      });
    }
    
    // Update list with new data
    const updatedData = {
      name: name !== undefined ? name : existingList.name,
      items: items !== undefined ? items : existingList.items,
      progress: progress !== undefined ? progress : existingList.progress,
      time: time !== undefined ? time : existingList.time,
      icon: icon !== undefined ? icon : existingList.icon,
      category: category !== undefined ? category : existingList.category,
      priority: priority !== undefined ? priority : existingList.priority,
    };
    
    const updatedList = await store.update(id, updatedData);
    res.json(updatedList);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to update list',
      message: error.message
    });
  }
};

// Delete list
const deleteList = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if list exists
    const existingList = await store.getById(id);
    if (!existingList) {
      return res.status(404).json({
        error: 'Not Found',
        message: `List with ID ${id} not found`
      });
    }
    
    await store.remove(id);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({
      error: 'Failed to delete list',
      message: error.message
    });
  }
};

  // --- Item-level handlers ---
  // Get items for a list
  const getListItems = async (req, res) => {
    try {
      const { id } = req.params;
      const list = await store.getById(id);
      if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });
      res.json(list.listItems || []);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch items', message: error.message });
    }
  };

  // Add item to a list (accepts optional 'priority')
  const addListItem = async (req, res) => {
    try {
      const { id } = req.params;
      const { name, name_ar, qty, priority, emoji } = req.body;
      if (!name) return res.status(400).json({ error: 'Bad Request', message: 'Missing item name' });

      const list = await store.getById(id);
      if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });

      const newItem = {
        id: uuidv4(),
        name,
        qty: qty || 1,
        checked: false,
      };
      if (name_ar !== undefined && name_ar !== '') newItem.name_ar = name_ar;
      if (priority !== undefined) newItem.priority = priority;
      if (emoji !== undefined) newItem.emoji = emoji;

      list.listItems = list.listItems || [];
      list.listItems.push(newItem);

      await store.update(id, list);
      console.log('[DEBUG] After store.update, listItems:', list.listItems.map(i => i.name));

      // Fetch the updated list from DB to ensure it's saved
      const updatedList = await store.getById(id);
      console.log('[DEBUG] After store.getById, listItems:', updatedList.listItems.map(i => i.name));

      // Respond with the full updated listItems array
      res.status(201).json(updatedList.listItems || []);
    } catch (error) {
      res.status(500).json({ error: 'Failed to add item', message: error.message });
    }
  };

  // Update an item
  const updateListItem = async (req, res) => {
    try {
      const { id, itemId } = req.params;
  const { name, name_ar, qty, checked, priority } = req.body;
      const list = await store.getById(id);
      if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });

      list.listItems = list.listItems || [];
      const idx = list.listItems.findIndex(it => it.id === itemId);
      if (idx === -1) return res.status(404).json({ error: 'Not Found', message: `Item ${itemId} not found` });

      const item = list.listItems[idx];
        const updatedItem = {
          id: item.id,
          name: name !== undefined ? name : item.name,
          name_ar: name_ar !== undefined ? name_ar : (item.name_ar || ''),
          qty: qty !== undefined ? qty : item.qty,
          checked: checked !== undefined ? checked : item.checked,
          emoji: item.emoji !== undefined ? item.emoji : undefined,
        };
        if (priority !== undefined) updatedItem.priority = priority;
        else if (item.priority !== undefined) updatedItem.priority = item.priority;

      list.listItems[idx] = updatedItem;

      await store.update(id, list);
      res.json(list.listItems[idx]);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update item', message: error.message });
    }
  };

  // Delete an item
  const deleteListItem = async (req, res) => {
    try {
      const { id, itemId } = req.params;
      const list = await store.getById(id);
      if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });

      list.listItems = list.listItems || [];
      const idx = list.listItems.findIndex(it => it.id === itemId);
      if (idx === -1) return res.status(404).json({ error: 'Not Found', message: `Item ${itemId} not found` });

      list.listItems.splice(idx, 1);
      await store.update(id, list);
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete item', message: error.message });
    }
  };


module.exports = {
  getAllLists,
  getListById,
  createList,
  updateList,
  getListItems,
  addListItem,
  updateListItem,
  deleteListItem,
  deleteList,
  generateInviteLink,
  getInvitePreview,
  acceptInvite,
  rejectInvite,
  migrateGuestLists,
};
