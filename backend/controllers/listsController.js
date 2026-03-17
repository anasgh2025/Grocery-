// --- Invite Link Handlers ---
const crypto = require('crypto');
const inviteTokens = new Map(); // In-memory for now; use DB for production

// Generate invite link for a list
const generateInviteLink = async (req, res) => {
  try {
    const { id } = req.params;
    const list = await store.getById(id);
    if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });
    // Generate a unique token
    const token = crypto.randomBytes(16).toString('hex');
    inviteTokens.set(token, { listId: id, created: Date.now() });
    // Construct invite URL (assume frontend at /invite/:token)
    const baseUrl = process.env.FRONTEND_URL || 'https://shopsmart.app';
    const inviteUrl = `${baseUrl}/invite/${token}`;
    res.json({ inviteUrl, token });
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate invite link', message: error.message });
  }
};

// Accept invite and link user to list
// POST /lists/accept-invite
// Body: { token: string, userId: string }
const acceptInvite = async (req, res) => {
  try {
    const { token, userId } = req.body;
    if (!token || !userId) {
      return res.status(400).json({ error: 'Bad Request', message: 'Missing token or userId' });
    }
    const invite = inviteTokens.get(token);
    if (!invite) {
      return res.status(404).json({ error: 'Invalid or expired invite token' });
    }
    const { listId } = invite;
    const list = await store.getById(listId);
    if (!list) {
      return res.status(404).json({ error: 'List not found' });
    }
    // Add userId to list.sharedWith (create if missing)
    if (!Array.isArray(list.sharedWith)) list.sharedWith = [];
    if (!list.sharedWith.includes(userId)) {
      list.sharedWith.push(userId);
      await store.update(listId, list);
    }
    // Optionally, delete the token after use
    inviteTokens.delete(token);
    res.json({ success: true, listId });
  } catch (error) {
    res.status(500).json({ error: 'Failed to accept invite', message: error.message });
  }
};
const { v4: uuidv4 } = require('uuid');
const store = require('../data/listsStore.mongodb');

// Get all lists
const getAllLists = async (req, res) => {
  try {
    const lists = await store.getAll();
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

    // Check for duplicate list name (case-insensitive)
    const allLists = await store.getAll();
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
  acceptInvite,
};
