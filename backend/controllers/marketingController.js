const store = require('../data/marketingStore');

// Get all marketing cards
const getAllCards = (req, res) => {
  try {
    const cards = store.getAll();
    res.json(cards);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch marketing cards',
      message: error.message
    });
  }
};

// Get single marketing card by ID
const getCardById = (req, res) => {
  try {
    const { id } = req.params;
    const card = store.getById(id);
    
    if (!card) {
      return res.status(404).json({
        error: 'Not Found',
        message: `Marketing card with ID ${id} not found`
      });
    }
    
    res.json(card);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch marketing card',
      message: error.message
    });
  }
};

// Create new marketing card
const createCard = (req, res) => {
  try {
    const { id, title, subtitle, imageUrl, order } = req.body;
    
    // Validate required fields
    if (!id || !title || !subtitle || !imageUrl || order === undefined) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Missing required fields: id, title, subtitle, imageUrl, order'
      });
    }
    
    const newCard = {
      id,
      title,
      subtitle,
      imageUrl,
      order
    };
    
    const createdCard = store.create(newCard);
    res.status(201).json(createdCard);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to create marketing card',
      message: error.message
    });
  }
};

// Update existing marketing card
const updateCard = (req, res) => {
  try {
    const { id } = req.params;
    const { title, subtitle, imageUrl, order } = req.body;
    
    // Check if card exists
    const existingCard = store.getById(id);
    if (!existingCard) {
      return res.status(404).json({
        error: 'Not Found',
        message: `Marketing card with ID ${id} not found`
      });
    }
    
    // Update card with new data
    const updatedData = {
      title: title !== undefined ? title : existingCard.title,
      subtitle: subtitle !== undefined ? subtitle : existingCard.subtitle,
      imageUrl: imageUrl !== undefined ? imageUrl : existingCard.imageUrl,
      order: order !== undefined ? order : existingCard.order
    };
    
    const updatedCard = store.update(id, updatedData);
    res.json(updatedCard);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to update marketing card',
      message: error.message
    });
  }
};

// Delete marketing card
const deleteCard = (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if card exists
    const existingCard = store.getById(id);
    if (!existingCard) {
      return res.status(404).json({
        error: 'Not Found',
        message: `Marketing card with ID ${id} not found`
      });
    }
    
    store.remove(id);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({
      error: 'Failed to delete marketing card',
      message: error.message
    });
  }
};

module.exports = {
  getAllCards,
  getCardById,
  createCard,
  updateCard,
  deleteCard
};
