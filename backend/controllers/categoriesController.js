const { v4: uuidv4 } = require('uuid');
const store = require('../data/categoriesStore.mongodb');

// GET all categories (returns label, icon, order, item count – without full items array)
const getAllCategories = async (req, res) => {
  try {
    const categories = await store.getAll();
    // Return summary (without heavy items array) unless ?full=true
    const lang = req.query.lang === 'ar' ? 'ar' : 'en';
    if (req.query.full === 'true') {
      // Return all fields, but localize if lang=ar
      if (lang === 'ar') {
        return res.json(categories.map(cat => ({
          ...cat,
          label: cat.label_ar || cat.label,
          items: cat.items.map(it => ({ ...it, name: it.name_ar || it.name }))
        })));
      } else {
        return res.json(categories);
      }
    }
    // Summary mode: only top-level info, localize label
    const summary = categories.map(({ items, label, label_ar, ...rest }) => ({
      ...rest,
      label: lang === 'ar' ? (label_ar || label) : label,
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
    if (req.query.lang === 'ar' && cat) {
      cat.label = cat.label_ar || cat.label;
      cat.items = cat.items.map(it => ({ ...it, name: it.name_ar || it.name }));
    }
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
