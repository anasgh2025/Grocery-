const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/categoriesController');

// GET all categories (summary by default, ?full=true for items)
router.get('/', ctrl.getAllCategories);

// GET category by label (e.g. /api/categories/label/Fruits)
router.get('/label/:label', ctrl.getCategoryByLabel);

// GET single category by id
router.get('/:id', ctrl.getCategoryById);

// POST create a category
router.post('/', ctrl.createCategory);

// PUT update a category
router.put('/:id', ctrl.updateCategory);

// DELETE a category
router.delete('/:id', ctrl.deleteCategory);

module.exports = router;
