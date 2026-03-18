'use strict';

const express = require('express');
const router = express.Router();
const usersController = require('../controllers/usersController');
const { requireAuth } = require('../middleware/auth');

// POST create user
router.post('/', usersController.createUser);

// POST login
router.post('/login', usersController.loginUser);

// PUT change password (requires JWT)
router.put('/me/password', requireAuth, usersController.changePassword);

// DELETE account (requires JWT)
router.delete('/me', requireAuth, usersController.deleteAccount);

// GET users (debug)
router.get('/', usersController.listUsers);

module.exports = router;
