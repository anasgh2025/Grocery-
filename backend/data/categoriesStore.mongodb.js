// Search for items by name (across all categories, case-insensitive, supports Arabic)
const searchItems = async (query, lang = 'en') => {
  if (!query || query.length < 3) return [];
  const regex = new RegExp(query, 'i');
  const docs = await Category.find().lean();
  let results = [];
  for (const cat of docs) {
    for (const item of cat.items) {
      const name = lang === 'ar' ? (item.name_ar || item.name) : item.name;
      if (name && regex.test(name)) {
        results.push({
          name: item.name,
          name_ar: item.name_ar,
          emoji: item.emoji,
          categoryId: cat.id,
          categoryLabel: cat.label,
          categoryLabelAr: cat.label_ar,
        });
      }
    }
  }
  return results;
};
const mongoose = require('mongoose');

// ── Schema ──────────────────────────────────────────────────────────────
const categoryItemSchema = new mongoose.Schema({
  name:    { type: String, required: true },
  name_ar: { type: String, required: false },
  emoji:   { type: String, default: '🛒' },
}, { _id: false });

const categorySchema = new mongoose.Schema({
  id:      { type: String, required: true, unique: true },
  label:   { type: String, required: true },
  label_ar:{ type: String, required: false },
  icon:    { type: String, default: 'shopping_bag' },   // Flutter icon name
  order:   { type: Number, default: 0 },
  items:   { type: [categoryItemSchema], default: [] },
}, { timestamps: true });

const Category = mongoose.model('Category', categorySchema);

// ── Helpers ─────────────────────────────────────────────────────────────
const toPlain = (doc) => {
  if (!doc) return null;
  const obj = doc.toObject();
  delete obj._id;
  delete obj.__v;
  delete obj.createdAt;
  delete obj.updatedAt;
  return obj;
};

// ── Default seed data (matches the old hard-coded Flutter map) ──────────
const defaultCategories = [
  // Example: Arabic-only demo category
 
  {
    id: 'cat-fruits',
    label: 'Fruits',
    label_ar: 'فواكه',
    icon: 'apple',
    order: 1,
    items: [
      { name: 'Apple', name_ar: 'تفاح', emoji: '🍎' },
      { name: 'Banana', name_ar: 'موز', emoji: '🍌' },
      { name: 'Orange', name_ar: 'برتقال', emoji: '🍊' },
      { name: 'Mango', name_ar: 'مانجو', emoji: '🥭' },
      { name: 'Watermelon', name_ar: 'بطيخ', emoji: '🍉' },
      { name: 'Melon', name_ar: 'شمام', emoji: '🍈' },
      { name: 'Strawberry', name_ar: 'فراولة', emoji: '🍓' },
      { name: 'Grapes', name_ar: 'عنب', emoji: '🍇' },
      { name: 'Pineapple', name_ar: 'أناناس', emoji: '🍍' },
      { name: 'Pear', name_ar: 'كمثرى', emoji: '🍐' },
      { name: 'Peach', name_ar: 'خوخ', emoji: '🍑' },
      { name: 'Cherry', name_ar: 'كرز', emoji: '🍒' },
      { name: 'Kiwi', name_ar: 'كيوي', emoji: '🥝' },
      { name: 'Papaya', name_ar: 'بابايا', emoji: '🥭' },
      { name: 'Dragon Fruit', name_ar: 'فاكهة التنين', emoji: '🐉' },
      { name: 'Guava', name_ar: 'جوافة', emoji: '🍈' },
      { name: 'Pomegranate', name_ar: 'رمان', emoji: '🍎' },
      { name: 'Fig', name_ar: 'تين', emoji: '🍇' },
      { name: 'Date', name_ar: 'تمر', emoji: '🌴' },
      { name: 'Avocado', name_ar: 'أفوكادو', emoji: '🥑' }
    ]
  },

  {
    id: 'cat-vegetables',
    label: 'Vegetables',
    label_ar: 'خضروات',
    icon: 'leaf',
    order: 2,
    items: [
      { name: 'Tomato', name_ar: 'طماطم', emoji: '🍅' },
      { name: 'Potato', name_ar: 'بطاطس', emoji: '🥔' },
      { name: 'Onion', name_ar: 'بصل', emoji: '🧅' },
      { name: 'Garlic', name_ar: 'ثوم', emoji: '🧄' },
      { name: 'Carrot', name_ar: 'جزر', emoji: '🥕' },
      { name: 'Cucumber', name_ar: 'خيار', emoji: '🥒' },
      { name: 'Eggplant', name_ar: 'باذنجان', emoji: '🍆' },
      { name: 'Bell Pepper', name_ar: 'فلفل رومي', emoji: '🫑' },
      { name: 'Chili Pepper', name_ar: 'فلفل حار', emoji: '🌶️' },
      { name: 'Zucchini', name_ar: 'كوسة', emoji: '🥒' },
      { name: 'Cabbage', name_ar: 'ملفوف', emoji: '🥬' },
      { name: 'Cauliflower', name_ar: 'قرنبيط', emoji: '🥦' },
      { name: 'Broccoli', name_ar: 'بروكلي', emoji: '🥦' },
      { name: 'Spinach', name_ar: 'سبانخ', emoji: '🥬' },
      { name: 'Lettuce', name_ar: 'خس', emoji: '🥬' },
      { name: 'Mushroom', name_ar: 'فطر', emoji: '🍄' },
      { name: 'Sweet Corn', name_ar: 'ذرة', emoji: '🌽' },
      { name: 'Green Beans', name_ar: 'فاصوليا خضراء', emoji: '🫛' },
      { name: 'Peas', name_ar: 'بازلاء', emoji: '🫛' },
      { name: 'Okra', name_ar: 'بامية', emoji: '🌿' }
    ]
  },

  {
    id: 'cat-meat',
    label: 'Meat & Poultry',
    label_ar: 'لحوم ودواجن',
    icon: 'drumstick',
    order: 3,
    items: [
      { name: 'Chicken Breast', name_ar: 'صدر دجاج', emoji: '🍗' },
      { name: 'Whole Chicken', name_ar: 'دجاج كامل', emoji: '🍗' },
      { name: 'Chicken Wings', name_ar: 'أجنحة دجاج', emoji: '🍗' },
      { name: 'Chicken Thighs', name_ar: 'أفخاذ دجاج', emoji: '🍗' },
      { name: 'Beef Steak', name_ar: 'ستيك لحم بقري', emoji: '🥩' },
      { name: 'Beef Mince', name_ar: 'لحم مفروم', emoji: '🥩' },
      { name: 'Lamb Chops', name_ar: 'ريش غنم', emoji: '🍖' },
      { name: 'Lamb Leg', name_ar: 'فخذ غنم', emoji: '🍖' },
      { name: 'Goat Meat', name_ar: 'لحم ماعز', emoji: '🥩' },
      { name: 'Turkey', name_ar: 'ديك رومي', emoji: '🍗' }
    ]
  },

  {
    id: 'cat-seafood',
    label: 'Fish & Seafood',
    label_ar: 'سمك ومأكولات بحرية',
    icon: 'fish',
    order: 4,
    items: [
      { name: 'Hammour Fish', name_ar: 'هامور', emoji: '🐟' },
      { name: 'Kingfish', name_ar: 'كنعد', emoji: '🐟' },
      { name: 'Salmon', name_ar: 'سلمون', emoji: '🐟' },
      { name: 'Tuna', name_ar: 'تونة', emoji: '🐟' },
      { name: 'Shrimp', name_ar: 'روبيان', emoji: '🦐' },
      { name: 'Crab', name_ar: 'سلطعون', emoji: '🦀' },
      { name: 'Lobster', name_ar: 'جراد البحر', emoji: '🦞' },
      { name: 'Octopus', name_ar: 'أخطبوط', emoji: '🐙' },
      { name: 'Oyster', name_ar: 'محار', emoji: '🦪' },
      { name: 'Squid', name_ar: 'حبار', emoji: '🦑' }
    ]
  },

  {
    id: 'cat-dairy',
    label: 'Dairy & Eggs',
    label_ar: 'ألبان وبيض',
    icon: 'milk',
    order: 5,
    items: [
      { name: 'Milk', name_ar: 'حليب', emoji: '🥛' },
      { name: 'Camel Milk', name_ar: 'حليب الإبل', emoji: '🥛' },
      { name: 'Yogurt', name_ar: 'زبادي', emoji: '🥣' },
      { name: 'Greek Yogurt', name_ar: 'زبادي يوناني', emoji: '🥣' },
      { name: 'Labneh', name_ar: 'لبنة', emoji: '🥛' },
      { name: 'Cheddar Cheese', name_ar: 'جبنة شيدر', emoji: '🧀' },
      { name: 'Mozzarella', name_ar: 'موزاريلا', emoji: '🧀' },
      { name: 'Feta Cheese', name_ar: 'جبنة فيتا', emoji: '🧀' },
      { name: 'Butter', name_ar: 'زبدة', emoji: '🧈' },
      { name: 'Eggs', name_ar: 'بيض', emoji: '🥚' }
    ]
  },

  {
    id: 'cat-rice-grains',
    label: 'Rice, Grains & Pasta',
    label_ar: 'أرز وحبوب ومكرونة',
    icon: 'grain',
    order: 6,
    items: [
      { name: 'Basmati Rice', name_ar: 'أرز بسمتي', emoji: '🍚' },
      { name: 'Jasmine Rice', name_ar: 'أرز ياسمين', emoji: '🍚' },
      { name: 'Brown Rice', name_ar: 'أرز بني', emoji: '🍚' },
      { name: 'White Rice', name_ar: 'أرز أبيض', emoji: '🍚' },
      { name: 'Pasta', name_ar: 'مكرونة', emoji: '🍝' },
      { name: 'Spaghetti', name_ar: 'سباغيتي', emoji: '🍝' },
      { name: 'Macaroni', name_ar: 'مكرونة قصيرة', emoji: '🍝' },
      { name: 'Oats', name_ar: 'شوفان', emoji: '🌾' },
      { name: 'Quinoa', name_ar: 'كينوا', emoji: '🌾' },
      { name: 'Bulgur', name_ar: 'برغل', emoji: '🌾' }
    ]
  },

  {
    id: 'cat-spices',
    label: 'Spices & Herbs',
    label_ar: 'بهارات وأعشاب',
    icon: 'pepper',
    order: 7,
    items: [
      { name: 'Salt', name_ar: 'ملح', emoji: '🧂' },
      { name: 'Black Pepper', name_ar: 'فلفل أسود', emoji: '🧂' },
      { name: 'Cumin', name_ar: 'كمون', emoji: '🌿' },
      { name: 'Coriander', name_ar: 'كزبرة', emoji: '🌿' },
      { name: 'Turmeric', name_ar: 'كركم', emoji: '🌿' },
      { name: 'Paprika', name_ar: 'بابريكا', emoji: '🌶️' },
      { name: 'Zaatar', name_ar: 'زعتر', emoji: '🌿' },
      { name: 'Sumac', name_ar: 'سماق', emoji: '🌿' },
      { name: 'Saffron', name_ar: 'زعفران', emoji: '🌸' },
      { name: 'Baharat', name_ar: 'بهارات مشكلة', emoji: '🌿' }
    ]
  },

  {
    id: 'cat-snacks',
    label: 'Snacks & Sweets',
    label_ar: 'وجبات خفيفة وحلويات',
    icon: 'cookie',
    order: 8,
    items: [
      { name: 'Chips', name_ar: 'شيبس', emoji: '🥔' },
      { name: 'Popcorn', name_ar: 'فشار', emoji: '🍿' },
      { name: 'Chocolate', name_ar: 'شوكولاتة', emoji: '🍫' },
      { name: 'Biscuits', name_ar: 'بسكويت', emoji: '🍪' },
      { name: 'Dates Sweets', name_ar: 'حلوى التمر', emoji: '🌴' },
      { name: 'Baklava', name_ar: 'بقلاوة', emoji: '🍯' },
      { name: 'Kunafa', name_ar: 'كنافة', emoji: '🍰' },
      { name: 'Halva', name_ar: 'حلاوة', emoji: '🍯' }
    ]
  },

  {
    id: 'cat-drinks',
    label: 'Beverages',
    label_ar: 'مشروبات',
    icon: 'cup',
    order: 9,
    items: [
      { name: 'Water', name_ar: 'ماء', emoji: '💧' },
      { name: 'Sparkling Water', name_ar: 'مياه غازية', emoji: '💧' },
      { name: 'Orange Juice', name_ar: 'عصير برتقال', emoji: '🧃' },
      { name: 'Apple Juice', name_ar: 'عصير تفاح', emoji: '🧃' },
      { name: 'Mango Juice', name_ar: 'عصير مانجو', emoji: '🧃' },
      { name: 'Soft Drinks', name_ar: 'مشروبات غازية', emoji: '🥤' },
      { name: 'Coffee', name_ar: 'قهوة', emoji: '☕' },
      { name: 'Arabic Coffee', name_ar: 'قهوة عربية', emoji: '☕' },
      { name: 'Tea', name_ar: 'شاي', emoji: '🍵' }
    ]
  },
];

// ── Seed defaults ──────────────────────────────────────────────────────
const seedDefaults = async () => {
  const count = await Category.countDocuments();
  if (count === 0) {
    await Category.insertMany(defaultCategories);
    console.log(`🌱 Seeded ${defaultCategories.length} default categories`);
  } else {
    console.log(`📦 Categories collection already has ${count} documents – skip seed`);
  }
};

// ── CRUD ────────────────────────────────────────────────────────────────
const getAll = async () => {
  const docs = await Category.find().sort({ order: 1 }).lean();
  return docs.map(({ _id, __v, createdAt, updatedAt, ...rest }) => rest);
};

const getById = async (id) => {
  const doc = await Category.findOne({ id });
  return doc ? toPlain(doc) : null;
};

const getByLabel = async (label) => {
  // Case-insensitive match on both label and label_ar
  const doc = await Category.findOne({
    $or: [
      { label: { $regex: `^${label}$`, $options: 'i' } },
      { label_ar: { $regex: `^${label}$`, $options: 'i' } }
    ]
  });
  return doc ? toPlain(doc) : null;
};

const create = async (catData) => {
  const doc = await Category.create(catData);
  return toPlain(doc);
};

const update = async (id, catData) => {
  const existing = await Category.findOne({ id });
  if (!existing) return null;

  if (catData.label !== undefined) existing.label = catData.label;
  if (catData.icon !== undefined) existing.icon = catData.icon;
  if (catData.order !== undefined) existing.order = catData.order;
  if (catData.items !== undefined) {
    existing.items = catData.items.map(it => ({ ...it }));
    existing.markModified('items');
  }

  await existing.save();
  return toPlain(existing);
};

const remove = async (id) => {
  const result = await Category.deleteOne({ id });
  return result.deletedCount > 0;
};

module.exports = {
  getAll,
  getById,
  getByLabel,
  create,
  update,
  remove,
  seedDefaults,
  Category,
  searchItems,
};
