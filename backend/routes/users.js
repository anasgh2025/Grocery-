const express = require('express');
const router = express.Router();
const usersController = require('../controllers/usersController');

// POST create user
router.post('/', usersController.createUser);

// POST login
router.post('/login', usersController.loginUser);

// GET users (debug)
router.get('/', usersController.listUsers);

module.exports = router;
