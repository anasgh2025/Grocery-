const fs = require('fs');
const path = require('path');

// File where we persist the store
const DATA_FILE = path.join(__dirname, 'store.json');

// Default data used when no persisted file exists
const defaultLists = [
  {
    id: '1',
    name: 'Weekly Groceries',
    items: '12/20',
    progress: 0.6,
    time: 'Due Tomorrow',
    icon: 'shopping_cart',
    listItems: [
      { id: 'i1', name: 'Milk', qty: 2, checked: false },
      { id: 'i2', name: 'Eggs', qty: 12, checked: false },
      { id: 'i3', name: 'Bread', qty: 1, checked: true }
    ]
  },
  {
    id: '2',
    name: 'Party Supplies',
    items: '8/15',
    progress: 0.53,
    time: 'Due in 3 days',
    icon: 'celebration',
    listItems: [
      { id: 'i1', name: 'Plates', qty: 20, checked: false },
      { id: 'i2', name: 'Cups', qty: 20, checked: false }
    ]
  },
  {
    id: '3',
    name: 'Breakfast Essentials',
    items: '5/8',
    progress: 0.63,
    time: 'Due Today',
    icon: 'breakfast',
    listItems: [
      { id: 'i1', name: 'Cereal', qty: 1, checked: false },
      { id: 'i2', name: 'Orange Juice', qty: 2, checked: false }
    ]
  },
  {
    id: '4',
    name: 'Cleaning Supplies',
    items: '3/10',
    progress: 0.3,
    time: 'Due in 5 days',
    icon: 'cleaning',
    listItems: [
      { id: 'i1', name: 'Detergent', qty: 1, checked: false }
    ]
  },
  {
    id: '5',
    name: 'Fresh Produce',
    items: '10/12',
    progress: 0.83,
    time: 'Due Today',
    icon: 'apple',
    listItems: [
      { id: 'i1', name: 'Apples', qty: 6, checked: false },
      { id: 'i2', name: 'Lettuce', qty: 2, checked: false }
    ]
  },
  {
    id: '6',
    name: 'Pantry Restock',
    items: '6/18',
    progress: 0.33,
    time: 'Due in 1 week',
    icon: 'inventory',
    listItems: [
      { id: 'i1', name: 'Rice', qty: 1, checked: false }
    ]
  }
];

let lists = [];

// Helpers
const safeQty = (qty) => (typeof qty === 'number' && !Number.isNaN(qty) && qty > 0) ? qty : 1;

const recomputeMetadata = (list) => {
  if (!list) return;
  const items = list.listItems || [];
  let totalQty = 0;
  let checkedQty = 0;

  for (const it of items) {
    const q = safeQty(it.qty);
    totalQty += q;
    if (it.checked) checkedQty += q;
  }

  list.items = `${checkedQty}/${totalQty}`;
  list.progress = totalQty > 0 ? +(checkedQty / totalQty).toFixed(2) : 0;
};

const saveToDisk = () => {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(lists, null, 2), 'utf8');
  } catch (err) {
    // Log but don't crash the server
    // eslint-disable-next-line no-console
    console.error('Failed to save store to disk:', err.message);
  }
};

const loadFromDisk = () => {
  try {
    if (fs.existsSync(DATA_FILE)) {
      const raw = fs.readFileSync(DATA_FILE, 'utf8');
      const parsed = JSON.parse(raw);
      if (Array.isArray(parsed)) {
        lists = parsed;
        // ensure metadata consistent
        lists.forEach(recomputeMetadata);
        return;
      }
    }
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error('Failed to load store from disk, using defaults:', err.message);
  }

  // Fallback to defaults
  lists = defaultLists.map(l => ({ ...l }));
  lists.forEach(recomputeMetadata);
  saveToDisk();
};

// Initialize
loadFromDisk();

// Get all lists
const getAll = () => {
  return [...lists];
};

// Get list by ID
const getById = (id) => {
  return lists.find(list => list.id === id);
};

// Create new list
const create = (listData) => {
  const newList = {
    ...listData,
    listItems: listData.listItems ? [...listData.listItems] : []
  };
  // ensure metadata
  recomputeMetadata(newList);
  lists.push(newList);
  saveToDisk();
  return newList;
};

// Update existing list
const update = (id, listData) => {
  const index = lists.findIndex(list => list.id === id);
  if (index === -1) {
    return null;
  }

  // Preserve existing id and merge
  const merged = {
    id,
    ...listData
  };

  // If the caller passed a full list object (with listItems), keep it
  if (listData.listItems) {
    merged.listItems = [...listData.listItems];
  } else if (lists[index].listItems) {
    // otherwise preserve existing items
    merged.listItems = [...lists[index].listItems];
  }

  // Recompute metadata and save
  recomputeMetadata(merged);
  lists[index] = merged;
  saveToDisk();
  return lists[index];
};

// Delete list
const remove = (id) => {
  const index = lists.findIndex(list => list.id === id);
  if (index === -1) {
    return false;
  }

  lists.splice(index, 1);
  saveToDisk();
  return true;
};

// Reset to default data (useful for testing)
const reset = () => {
  lists = defaultLists.map(l => ({ ...l }));
  lists.forEach(recomputeMetadata);
  saveToDisk();
};

module.exports = {
  getAll,
  getById,
  create,
  update,
  remove,
  reset
};
