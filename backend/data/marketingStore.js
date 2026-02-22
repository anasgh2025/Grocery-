// In-memory data store for marketing cards
let marketingCards = [
  {
    id: '1',
    title: 'Fresh Organic Produce',
    subtitle: 'Get 20% off on all organic vegetables',
    imageUrl: '/assets/images/bk.png',
    order: 1
  },
  {
    id: '2',
    title: 'Weekly Meal Deals',
    subtitle: 'Save big on family meal bundles',
    imageUrl: '/assets/images/bk.png',
    order: 2
  }
];

// Get all marketing cards
const getAll = () => {
  return [...marketingCards].sort((a, b) => a.order - b.order);
};

// Get marketing card by ID
const getById = (id) => {
  return marketingCards.find(card => card.id === id);
};

// Create new marketing card
const create = (cardData) => {
  const newCard = {
    ...cardData
  };
  marketingCards.push(newCard);
  return newCard;
};

// Update existing marketing card
const update = (id, cardData) => {
  const index = marketingCards.findIndex(card => card.id === id);
  if (index === -1) {
    return null;
  }
  
  marketingCards[index] = {
    id,
    ...cardData
  };
  
  return marketingCards[index];
};

// Delete marketing card
const remove = (id) => {
  const index = marketingCards.findIndex(card => card.id === id);
  if (index === -1) {
    return false;
  }
  
  marketingCards.splice(index, 1);
  return true;
};

// Reset to default data
const reset = () => {
  marketingCards = [
    {
      id: '1',
      title: 'Fresh Organic Produce',
      subtitle: 'Get 20% off on all organic vegetables',
      imageUrl: '/assets/images/bk.png',
      order: 1
    },
    {
      id: '2',
      title: 'Weekly Meal Deals',
      subtitle: 'Save big on family meal bundles',
      imageUrl: '/assets/images/bk.png',
      order: 2
    }
  ];
};

module.exports = {
  getAll,
  getById,
  create,
  update,
  remove,
  reset
};
