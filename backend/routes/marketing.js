const express = require('express');
const router = express.Router();
const marketingController = require('../controllers/marketingController');

// GET all marketing cards
router.get('/', marketingController.getAllCards);

// GET single marketing card by ID
router.get('/:id', marketingController.getCardById);

// POST create new marketing card
router.post('/', marketingController.createCard);

// PUT update existing marketing card
router.put('/:id', marketingController.updateCard);

// DELETE marketing card
router.delete('/:id', marketingController.deleteCard);

module.exports = router;
