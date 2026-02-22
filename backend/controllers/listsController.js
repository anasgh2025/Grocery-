const { v4: uuidv4 } = require('uuid');
const store = require('../data/store');

// Get all lists
const getAllLists = (req, res) => {
  try {
    const lists = store.getAll();
    res.json(lists);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch lists',
      message: error.message
    });
  }
};

// Get single list by ID
const getListById = (req, res) => {
  try {
    const { id } = req.params;
    const list = store.getById(id);
    
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
const createList = (req, res) => {
  try {
    const { name, items, progress, time, icon } = req.body;
    
    // Validate required fields
    if (!name || items === undefined || progress === undefined || !time || !icon) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Missing required fields: name, items, progress, time, icon'
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
      icon
    };
    
    const createdList = store.create(newList);
    res.status(201).json(createdList);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to create list',
      message: error.message
    });
  }
};

// Update existing list
const updateList = (req, res) => {
  try {
    const { id } = req.params;
    const { name, items, progress, time, icon } = req.body;
    
    // Check if list exists
    const existingList = store.getById(id);
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
      icon: icon !== undefined ? icon : existingList.icon
    };
    
    const updatedList = store.update(id, updatedData);
    res.json(updatedList);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to update list',
      message: error.message
    });
  }
};

// Delete list
const deleteList = (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if list exists
    const existingList = store.getById(id);
    if (!existingList) {
      return res.status(404).json({
        error: 'Not Found',
        message: `List with ID ${id} not found`
      });
    }
    
    store.remove(id);
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
  const getListItems = (req, res) => {
    try {
      const { id } = req.params;
      const list = store.getById(id);
      if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });
      res.json(list.listItems || []);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch items', message: error.message });
    }
  };

  // Add item to a list (accepts optional 'priority')
  const addListItem = (req, res) => {
    try {
      const { id } = req.params;
      const { name, qty, priority } = req.body;
      if (!name) return res.status(400).json({ error: 'Bad Request', message: 'Missing item name' });

      const list = store.getById(id);
      if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });

      const newItem = { id: uuidv4(), name, qty: qty || 1, checked: false };
      // If client sent priority, persist it on the item
      if (priority !== undefined) newItem.priority = priority;

      list.listItems = list.listItems || [];
      list.listItems.push(newItem);

      // Optionally update items/progress counts here
      store.update(id, list);

      res.status(201).json(newItem);
    } catch (error) {
      res.status(500).json({ error: 'Failed to add item', message: error.message });
    }
  };

  // Update an item
  const updateListItem = (req, res) => {
    try {
      const { id, itemId } = req.params;
      const { name, qty, checked, priority } = req.body;
      const list = store.getById(id);
      if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });

      list.listItems = list.listItems || [];
      const idx = list.listItems.findIndex(it => it.id === itemId);
      if (idx === -1) return res.status(404).json({ error: 'Not Found', message: `Item ${itemId} not found` });

      const item = list.listItems[idx];
      const updatedItem = {
        id: item.id,
        name: name !== undefined ? name : item.name,
        qty: qty !== undefined ? qty : item.qty,
        checked: checked !== undefined ? checked : item.checked,
      };
      // preserve or update priority if provided
      if (priority !== undefined) updatedItem.priority = priority;
      else if (item.priority !== undefined) updatedItem.priority = item.priority;

      list.listItems[idx] = updatedItem;

      store.update(id, list);
      res.json(list.listItems[idx]);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update item', message: error.message });
    }
  };

  // Delete an item
  const deleteListItem = (req, res) => {
    try {
      const { id, itemId } = req.params;
      const list = store.getById(id);
      if (!list) return res.status(404).json({ error: 'Not Found', message: `List ${id} not found` });

      list.listItems = list.listItems || [];
      const idx = list.listItems.findIndex(it => it.id === itemId);
      if (idx === -1) return res.status(404).json({ error: 'Not Found', message: `Item ${itemId} not found` });

      list.listItems.splice(idx, 1);
      store.update(id, list);
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
  deleteList
};
