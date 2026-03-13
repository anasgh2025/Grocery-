
const express = require('express');
const router = express.Router();
const listsController = require('../controllers/listsController');

// Generate invite link for a list
router.post('/:id/invite', listsController.generateInviteLink);

// Accept invite and link user to list
router.post('/accept-invite', listsController.acceptInvite);

// GET all lists
router.get('/', listsController.getAllLists);

// GET single list by ID
router.get('/:id', listsController.getListById);

// Item routes for a specific list
router.get('/:id/items', listsController.getListItems);
router.post('/:id/items', listsController.addListItem);
router.put('/:id/items/:itemId', listsController.updateListItem);
router.delete('/:id/items/:itemId', listsController.deleteListItem);

// POST create new list
router.post('/', listsController.createList);

// PUT update existing list
router.put('/:id', listsController.updateList);

// DELETE list
router.delete('/:id', listsController.deleteList);

module.exports = router;
