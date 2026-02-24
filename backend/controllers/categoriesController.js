const { v4: uuidv4 } = require('uuid');
const store = require('../data/categoriesStore.mongodb');

// GET all categories (returns label, icon, order, item count – without full items array)
const getAllCategories = async (req, res) => {
  try {
    const categories = await store.getAll();
    // Return summary (without heavy items array) unless ?full=true
    if (req.query.full === 'true') {
      return res.json(categories);
    }
    const summary = categories.map(({ items, ...rest }) => ({
      ...rest,
      itemCount: items ? items.length : 0,
    }));
    res.json(summary);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch categories', message: error.message });
  }
};

// GET single category by id (includes items)
const getCategoryById = async (req, res) => {
  try {
    const cat = await store.getById(req.params.id);
    if (!cat) return res.status(404).json({ error: 'Not Found', message: `Category ${req.params.id} not found` });
    res.json(cat);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch category', message: error.message });
  }
};

// GET category by label (includes items) – convenient for Flutter
const getCategoryByLabel = async (req, res) => {
  try {
    const label = decodeURIComponent(req.params.label);
    const cat = await store.getByLabel(label);
    if (!cat) return res.status(404).json({ error: 'Not Found', message: `Category "${label}" not found` });
    res.json(cat);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch category', message: error.message });
  }
};

// POST create a new category
const createCategory = async (req, res) => {
  try {
    const { label, icon, order, items } = req.body;
    if (!label) return res.status(400).json({ error: 'Bad Request', message: 'Missing required field: label' });

    const newCat = {
      id: uuidv4(),
      label,
      icon: icon || 'shopping_bag',
      order: order !== undefined ? order : 99,
      items: items || [],
    };

    const created = await store.create(newCat);
    res.status(201).json(created);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create category', message: error.message });
  }
};

// PUT update a category
const updateCategory = async (req, res) => {
  try {
    const updated = await store.update(req.params.id, req.body);
    if (!updated) return res.status(404).json({ error: 'Not Found', message: `Category ${req.params.id} not found` });
    res.json(updated);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update category', message: error.message });
  }
};

// DELETE a category
const deleteCategory = async (req, res) => {
  try {
    const removed = await store.remove(req.params.id);
    if (!removed) return res.status(404).json({ error: 'Not Found', message: `Category ${req.params.id} not found` });
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete category', message: error.message });
  }
};

module.exports = {
  getAllCategories,
  getCategoryById,
  getCategoryByLabel,
  createCategory,
  updateCategory,
  deleteCategory,
};
