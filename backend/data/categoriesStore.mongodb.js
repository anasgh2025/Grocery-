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
  {
    id: 'cat-fruits', label: 'Fruits', label_ar: 'فواكه', icon: 'apple', order: 0,
    items: [
      { name: 'Apple', name_ar: 'تفاح', emoji: '🍎' },
      { name: 'Banana', name_ar: 'موز', emoji: '🍌' },
      { name: 'Orange', name_ar: 'برتقال', emoji: '🍊' },
      { name: 'Grapes', name_ar: 'عنب', emoji: '🍇' },
      { name: 'Strawberry', name_ar: 'فراولة', emoji: '🍓' },
      { name: 'Watermelon', name_ar: 'بطيخ', emoji: '🍉' },
      { name: 'Mango', name_ar: 'مانجو', emoji: '🥭' },
      { name: 'Pineapple', name_ar: 'أناناس', emoji: '🍍' },
      { name: 'Peach', name_ar: 'خوخ', emoji: '🍑' },
      { name: 'Pear', name_ar: 'كمثرى', emoji: '🍐' },
      { name: 'Cherry', name_ar: 'كرز', emoji: '🍒' },
      { name: 'Lemon', name_ar: 'ليمون', emoji: '🍋' },
      { name: 'Coconut', name_ar: 'جوز الهند', emoji: '🥥' },
      { name: 'Blueberry', name_ar: 'توت أزرق', emoji: '🫐' },
      { name: 'Kiwi', name_ar: 'كيوي', emoji: '🥝' },
      { name: 'Avocado', name_ar: 'أفوكادو', emoji: '🥑' },
      { name: 'Melon', name_ar: 'شمام', emoji: '🍈' },
      { name: 'Pomegranate', name_ar: 'رمان', emoji: '🍑' },
      { name: 'Plum', name_ar: 'برقوق', emoji: '🍑' },
      { name: 'Fig', name_ar: 'تين', emoji: '🫐' },
    ],
  },
  {
    id: 'cat-vegetables', label: 'Vegetables', icon: 'eco', order: 1,
    items: [
      { name: 'Carrot', emoji: '🥕' }, { name: 'Broccoli', emoji: '🥦' },
      { name: 'Spinach', emoji: '🥬' }, { name: 'Tomato', emoji: '🍅' },
      { name: 'Cucumber', emoji: '🥒' }, { name: 'Lettuce', emoji: '🥬' },
      { name: 'Onion', emoji: '🧅' }, { name: 'Garlic', emoji: '🧄' },
      { name: 'Potato', emoji: '🥔' }, { name: 'Sweet Potato', emoji: '🍠' },
      { name: 'Bell Pepper', emoji: '🫑' }, { name: 'Corn', emoji: '🌽' },
      { name: 'Mushroom', emoji: '🍄' }, { name: 'Celery', emoji: '🥬' },
      { name: 'Zucchini', emoji: '🥒' }, { name: 'Eggplant', emoji: '🍆' },
      { name: 'Cauliflower', emoji: '🥦' }, { name: 'Beetroot', emoji: '🫐' },
      { name: 'Asparagus', emoji: '🌿' }, { name: 'Peas', emoji: '🟢' },
    ],
  },
  {
    id: 'cat-meat', label: 'Meat', icon: 'set_meal', order: 2,
    items: [
      { name: 'Chicken Breast', emoji: '🍗' }, { name: 'Chicken Thighs', emoji: '🍗' },
      { name: 'Ground Beef', emoji: '🥩' }, { name: 'Beef Steak', emoji: '🥩' },
      { name: 'Lamb Chops', emoji: '🥩' }, { name: 'Pork Chops', emoji: '🥩' },
      { name: 'Bacon', emoji: '🥓' }, { name: 'Sausage', emoji: '🌭' },
      { name: 'Turkey', emoji: '🦃' }, { name: 'Veal', emoji: '🥩' },
      { name: 'Duck', emoji: '🦆' }, { name: 'Ribs', emoji: '🥩' },
      { name: 'Minced Lamb', emoji: '🥩' }, { name: 'Hot Dogs', emoji: '🌭' },
      { name: 'Deli Ham', emoji: '🥩' }, { name: 'Salami', emoji: '🥩' },
    ],
  },
  {
    id: 'cat-seafood', label: 'Seafood', icon: 'water', order: 3,
    items: [
      { name: 'Salmon', emoji: '🐟' }, { name: 'Tuna', emoji: '🐟' },
      { name: 'Shrimp', emoji: '🍤' }, { name: 'Crab', emoji: '🦀' },
      { name: 'Lobster', emoji: '🦞' }, { name: 'Sardines', emoji: '🐟' },
      { name: 'Cod', emoji: '🐟' }, { name: 'Tilapia', emoji: '🐠' },
      { name: 'Oysters', emoji: '🦪' }, { name: 'Mussels', emoji: '🦪' },
      { name: 'Clams', emoji: '🦪' }, { name: 'Squid', emoji: '🦑' },
      { name: 'Octopus', emoji: '🐙' }, { name: 'Scallops', emoji: '🍤' },
      { name: 'Mackerel', emoji: '🐟' }, { name: 'Anchovies', emoji: '🐟' },
    ],
  },
  {
    id: 'cat-dairy', label: 'Dairy', icon: 'egg_alt', order: 4,
    items: [
      { name: 'Milk', emoji: '🥛' }, { name: 'Eggs', emoji: '🥚' },
      { name: 'Butter', emoji: '🧈' }, { name: 'Cheddar Cheese', emoji: '🧀' },
      { name: 'Mozzarella', emoji: '🧀' }, { name: 'Cream Cheese', emoji: '🧀' },
      { name: 'Yogurt', emoji: '🥛' }, { name: 'Sour Cream', emoji: '🥛' },
      { name: 'Heavy Cream', emoji: '🥛' }, { name: 'Parmesan', emoji: '🧀' },
      { name: 'Feta Cheese', emoji: '🧀' }, { name: 'Ricotta', emoji: '🧀' },
      { name: 'Whipped Cream', emoji: '🥛' }, { name: 'Condensed Milk', emoji: '🥛' },
      { name: 'Kefir', emoji: '🥛' },
    ],
  },
  {
    id: 'cat-bakery', label: 'Bakery', icon: 'bakery_dining', order: 5,
    items: [
      { name: 'White Bread', emoji: '🍞' }, { name: 'Whole Wheat Bread', emoji: '🍞' },
      { name: 'Baguette', emoji: '🥖' }, { name: 'Croissant', emoji: '🥐' },
      { name: 'Bagel', emoji: '🥯' }, { name: 'Pita Bread', emoji: '🫓' },
      { name: 'Tortillas', emoji: '🫓' }, { name: 'Muffins', emoji: '🧁' },
      { name: 'Dinner Rolls', emoji: '🍞' }, { name: 'Sourdough', emoji: '🍞' },
      { name: 'Rye Bread', emoji: '🍞' }, { name: 'Brioche', emoji: '🍞' },
      { name: 'Pretzel', emoji: '🥨' }, { name: 'Donuts', emoji: '🍩' },
      { name: 'Waffles', emoji: '🧇' }, { name: 'Pancake Mix', emoji: '🥞' },
    ],
  },
  {
    id: 'cat-beverages', label: 'Beverages', icon: 'local_drink', order: 6,
    items: [
      { name: 'Water', emoji: '💧' }, { name: 'Orange Juice', emoji: '🍊' },
      { name: 'Apple Juice', emoji: '🍎' }, { name: 'Coffee', emoji: '☕' },
      { name: 'Tea', emoji: '🍵' }, { name: 'Soda', emoji: '🥤' },
      { name: 'Energy Drink', emoji: '⚡' }, { name: 'Milk', emoji: '🥛' },
      { name: 'Sparkling Water', emoji: '💦' }, { name: 'Lemonade', emoji: '🍋' },
      { name: 'Coconut Water', emoji: '🥥' }, { name: 'Sports Drink', emoji: '🏃' },
      { name: 'Green Tea', emoji: '🍵' }, { name: 'Hot Chocolate', emoji: '☕' },
      { name: 'Wine', emoji: '🍷' }, { name: 'Beer', emoji: '🍺' },
      { name: 'Smoothie', emoji: '🥤' }, { name: 'Almond Milk', emoji: '🥛' },
    ],
  },
  {
    id: 'cat-snacks', label: 'Snacks', icon: 'cookie', order: 7,
    items: [
      { name: 'Chips', emoji: '🥔' }, { name: 'Popcorn', emoji: '🍿' },
      { name: 'Crackers', emoji: '🫙' }, { name: 'Pretzels', emoji: '🥨' },
      { name: 'Nuts Mix', emoji: '🥜' }, { name: 'Almonds', emoji: '🥜' },
      { name: 'Cashews', emoji: '🥜' }, { name: 'Granola Bar', emoji: '🍫' },
      { name: 'Rice Cakes', emoji: '🍙' }, { name: 'Dried Fruit', emoji: '🍇' },
      { name: 'Fruit Snacks', emoji: '🍬' }, { name: 'Peanut Butter', emoji: '🥜' },
      { name: 'Hummus', emoji: '🫙' }, { name: 'Cheese Sticks', emoji: '🧀' },
      { name: 'Protein Bar', emoji: '💪' }, { name: 'Trail Mix', emoji: '🌰' },
    ],
  },
  {
    id: 'cat-frozen', label: 'Frozen', icon: 'ac_unit', order: 8,
    items: [
      { name: 'Ice Cream', emoji: '🍦' }, { name: 'Frozen Pizza', emoji: '🍕' },
      { name: 'Frozen Fries', emoji: '🍟' }, { name: 'Frozen Peas', emoji: '🟢' },
      { name: 'Frozen Corn', emoji: '🌽' }, { name: 'Frozen Berries', emoji: '🫐' },
      { name: 'Frozen Shrimp', emoji: '🍤' }, { name: 'Frozen Chicken', emoji: '🍗' },
      { name: 'Frozen Waffles', emoji: '🧇' }, { name: 'Sorbet', emoji: '🍧' },
      { name: 'Frozen Burrito', emoji: '🌯' }, { name: 'Frozen Lasagna', emoji: '🍝' },
      { name: 'Frozen Fish', emoji: '🐟' }, { name: 'Popsicles', emoji: '🧊' },
    ],
  },
  {
    id: 'cat-grains', label: 'Grains', icon: 'grain', order: 9,
    items: [
      { name: 'White Rice', emoji: '🍚' }, { name: 'Brown Rice', emoji: '🍚' },
      { name: 'Oats', emoji: '🌾' }, { name: 'Quinoa', emoji: '🌾' },
      { name: 'Barley', emoji: '🌾' }, { name: 'Bulgur', emoji: '🌾' },
      { name: 'Couscous', emoji: '🌾' }, { name: 'Corn Meal', emoji: '🌽' },
      { name: 'Breadcrumbs', emoji: '🍞' }, { name: 'Flour', emoji: '🌾' },
      { name: 'Cornstarch', emoji: '🌽' }, { name: 'Wheat Bran', emoji: '🌾' },
    ],
  },
  {
    id: 'cat-condiments', label: 'Condiments', icon: 'blender', order: 10,
    items: [
      { name: 'Ketchup', emoji: '🍅' }, { name: 'Mustard', emoji: '💛' },
      { name: 'Mayonnaise', emoji: '🫙' }, { name: 'Hot Sauce', emoji: '🌶️' },
      { name: 'Soy Sauce', emoji: '🫙' }, { name: 'Barbecue Sauce', emoji: '🍖' },
      { name: 'Ranch Dressing', emoji: '🫙' }, { name: 'Honey Mustard', emoji: '🍯' },
      { name: 'Salsa', emoji: '🍅' }, { name: 'Guacamole', emoji: '🥑' },
      { name: 'Relish', emoji: '🫙' }, { name: 'Sriracha', emoji: '🌶️' },
      { name: 'Worcestershire', emoji: '🫙' }, { name: 'Vinegar', emoji: '🫙' },
      { name: 'Olive Tapenade', emoji: '🫒' },
    ],
  },
  {
    id: 'cat-canned-goods', label: 'Canned Goods', icon: 'inventory_2', order: 11,
    items: [
      { name: 'Canned Tomatoes', emoji: '🥫' }, { name: 'Canned Tuna', emoji: '🥫' },
      { name: 'Canned Beans', emoji: '🥫' }, { name: 'Canned Corn', emoji: '🥫' },
      { name: 'Canned Peas', emoji: '🥫' }, { name: 'Canned Soup', emoji: '🥫' },
      { name: 'Tomato Paste', emoji: '🥫' }, { name: 'Coconut Milk', emoji: '🥫' },
      { name: 'Chickpeas', emoji: '🥫' }, { name: 'Kidney Beans', emoji: '🥫' },
      { name: 'Lentils', emoji: '🥫' }, { name: 'Canned Peaches', emoji: '🥫' },
      { name: 'Canned Pineapple', emoji: '🥫' }, { name: 'Sardines', emoji: '🥫' },
      { name: 'Canned Mushrooms', emoji: '🥫' },
    ],
  },
  {
    id: 'cat-spices', label: 'Spices', icon: 'spa', order: 12,
    items: [
      { name: 'Salt', emoji: '🧂' }, { name: 'Black Pepper', emoji: '⚫' },
      { name: 'Cumin', emoji: '🌿' }, { name: 'Paprika', emoji: '🌶️' },
      { name: 'Turmeric', emoji: '🟡' }, { name: 'Cinnamon', emoji: '🌿' },
      { name: 'Oregano', emoji: '🌿' }, { name: 'Basil', emoji: '🌿' },
      { name: 'Thyme', emoji: '🌿' }, { name: 'Bay Leaves', emoji: '🍃' },
      { name: 'Chili Flakes', emoji: '🌶️' }, { name: 'Garlic Powder', emoji: '🧄' },
      { name: 'Onion Powder', emoji: '🧅' }, { name: 'Ginger', emoji: '🫚' },
      { name: 'Cardamom', emoji: '🌿' }, { name: 'Nutmeg', emoji: '🌰' },
      { name: 'Coriander', emoji: '🌿' }, { name: 'Cloves', emoji: '🌿' },
    ],
  },
  {
    id: 'cat-oils-fats', label: 'Oils & Fats', icon: 'opacity', order: 13,
    items: [
      { name: 'Olive Oil', emoji: '🫒' }, { name: 'Vegetable Oil', emoji: '🫙' },
      { name: 'Coconut Oil', emoji: '🥥' }, { name: 'Butter', emoji: '🧈' },
      { name: 'Margarine', emoji: '🧈' }, { name: 'Canola Oil', emoji: '🫙' },
      { name: 'Sesame Oil', emoji: '🫙' }, { name: 'Avocado Oil', emoji: '🥑' },
      { name: 'Ghee', emoji: '🧈' }, { name: 'Lard', emoji: '🫙' },
      { name: 'Sunflower Oil', emoji: '🌻' },
    ],
  },
  {
    id: 'cat-sweets', label: 'Sweets', icon: 'cake', order: 14,
    items: [
      { name: 'Chocolate Bar', emoji: '🍫' }, { name: 'Candy', emoji: '🍬' },
      { name: 'Gummy Bears', emoji: '🐻' }, { name: 'Lollipop', emoji: '🍭' },
      { name: 'Marshmallows', emoji: '☁️' }, { name: 'Cookies', emoji: '🍪' },
      { name: 'Cake', emoji: '🎂' }, { name: 'Brownie', emoji: '🍫' },
      { name: 'Honey', emoji: '🍯' }, { name: 'Jam', emoji: '🍓' },
      { name: 'Maple Syrup', emoji: '🍁' }, { name: 'Nutella', emoji: '🍫' },
      { name: 'Ice Cream', emoji: '🍨' }, { name: 'Pudding', emoji: '🍮' },
      { name: 'Caramel', emoji: '🍯' }, { name: 'Jelly', emoji: '🫙' },
    ],
  },
  {
    id: 'cat-baby-food', label: 'Baby Food', icon: 'child_care', order: 15,
    items: [
      { name: 'Baby Formula', emoji: '🍼' }, { name: 'Pureed Veggies', emoji: '🥣' },
      { name: 'Pureed Fruits', emoji: '🥣' }, { name: 'Baby Cereal', emoji: '🌾' },
      { name: 'Teething Snacks', emoji: '🍪' }, { name: 'Baby Yogurt', emoji: '🥛' },
      { name: 'Baby Juice', emoji: '🧃' }, { name: 'Rice Puffs', emoji: '🌾' },
      { name: 'Baby Pouches', emoji: '🥣' }, { name: 'Baby Water', emoji: '💧' },
    ],
  },
  {
    id: 'cat-health', label: 'Health', icon: 'health_and_safety', order: 16,
    items: [
      { name: 'Protein Powder', emoji: '💪' }, { name: 'Vitamins', emoji: '💊' },
      { name: 'Fiber Supplement', emoji: '🌿' }, { name: 'Probiotics', emoji: '🦠' },
      { name: 'Fish Oil', emoji: '🐟' }, { name: 'Collagen', emoji: '✨' },
      { name: 'Multivitamin', emoji: '💊' }, { name: 'Chia Seeds', emoji: '🌱' },
      { name: 'Flax Seeds', emoji: '🌱' }, { name: 'Whey Protein', emoji: '💪' },
      { name: 'Herbal Tea', emoji: '🍵' }, { name: 'Apple Cider Vinegar', emoji: '🍎' },
    ],
  },
  {
    id: 'cat-cleaning', label: 'Cleaning', icon: 'cleaning_services', order: 17,
    items: [
      { name: 'Dish Soap', emoji: '🧴' }, { name: 'Laundry Detergent', emoji: '🧺' },
      { name: 'All-Purpose Spray', emoji: '🧹' }, { name: 'Bleach', emoji: '🫙' },
      { name: 'Floor Cleaner', emoji: '🧹' }, { name: 'Toilet Cleaner', emoji: '🚽' },
      { name: 'Glass Cleaner', emoji: '🪟' }, { name: 'Sponges', emoji: '🧽' },
      { name: 'Paper Towels', emoji: '🧻' }, { name: 'Trash Bags', emoji: '🗑️' },
      { name: 'Fabric Softener', emoji: '🌸' }, { name: 'Dryer Sheets', emoji: '🌸' },
      { name: 'Mop', emoji: '🧹' }, { name: 'Broom', emoji: '🧹' },
    ],
  },
  {
    id: 'cat-personal-care', label: 'Personal Care', icon: 'face', order: 18,
    items: [
      { name: 'Shampoo', emoji: '🧴' }, { name: 'Conditioner', emoji: '🧴' },
      { name: 'Body Wash', emoji: '🧼' }, { name: 'Soap Bar', emoji: '🧼' },
      { name: 'Toothpaste', emoji: '🦷' }, { name: 'Toothbrush', emoji: '🪥' },
      { name: 'Deodorant', emoji: '✨' }, { name: 'Moisturizer', emoji: '🧴' },
      { name: 'Sunscreen', emoji: '☀️' }, { name: 'Razor', emoji: '🪒' },
      { name: 'Shaving Cream', emoji: '🧴' }, { name: 'Facial Cleanser', emoji: '💆' },
      { name: 'Lip Balm', emoji: '💋' }, { name: 'Hand Sanitizer', emoji: '🤲' },
      { name: 'Tissue', emoji: '🧻' }, { name: 'Cotton Pads', emoji: '☁️' },
    ],
  },
  {
    id: 'cat-pet-food', label: 'Pet Food', icon: 'pets', order: 19,
    items: [
      { name: 'Dog Food (Dry)', emoji: '🐕' }, { name: 'Dog Food (Wet)', emoji: '🐕' },
      { name: 'Cat Food (Dry)', emoji: '🐈' }, { name: 'Cat Food (Wet)', emoji: '🐈' },
      { name: 'Dog Treats', emoji: '🦴' }, { name: 'Cat Treats', emoji: '🐾' },
      { name: 'Bird Seed', emoji: '🐦' }, { name: 'Fish Food', emoji: '🐠' },
      { name: 'Rabbit Pellets', emoji: '🐇' }, { name: 'Hamster Food', emoji: '🐹' },
      { name: 'Pet Milk', emoji: '🥛' }, { name: 'Dental Chews', emoji: '🦷' },
    ],
  },
  {
    id: 'cat-breakfast', label: 'Breakfast', icon: 'free_breakfast', order: 20,
    items: [
      { name: 'Cereal', emoji: '🥣' }, { name: 'Oatmeal', emoji: '🌾' },
      { name: 'Granola', emoji: '🌾' }, { name: 'Pancake Mix', emoji: '🥞' },
      { name: 'Waffle Mix', emoji: '🧇' }, { name: 'Orange Juice', emoji: '🍊' },
      { name: 'Maple Syrup', emoji: '🍁' }, { name: 'Jam', emoji: '🍓' },
      { name: 'Peanut Butter', emoji: '🥜' }, { name: 'Yogurt', emoji: '🥛' },
      { name: 'Eggs', emoji: '🥚' }, { name: 'Bacon', emoji: '🥓' },
      { name: 'Bagel', emoji: '🥯' }, { name: 'English Muffin', emoji: '🍞' },
      { name: 'Breakfast Bar', emoji: '🍫' },
    ],
  },
  {
    id: 'cat-pasta-rice', label: 'Pasta & Rice', icon: 'rice_bowl', order: 21,
    items: [
      { name: 'Spaghetti', emoji: '🍝' }, { name: 'Penne', emoji: '🍝' },
      { name: 'Fusilli', emoji: '🍝' }, { name: 'Fettuccine', emoji: '🍝' },
      { name: 'Lasagna Sheets', emoji: '🍝' }, { name: 'Macaroni', emoji: '🧀' },
      { name: 'White Rice', emoji: '🍚' }, { name: 'Brown Rice', emoji: '🍚' },
      { name: 'Basmati Rice', emoji: '🍚' }, { name: 'Jasmine Rice', emoji: '🍚' },
      { name: 'Arborio Rice', emoji: '🍚' }, { name: 'Noodles', emoji: '🍜' },
      { name: 'Rice Noodles', emoji: '🍜' }, { name: 'Vermicelli', emoji: '🍜' },
      { name: 'Egg Noodles', emoji: '🍜' },
    ],
  },
  {
    id: 'cat-deli', label: 'Deli', icon: 'lunch_dining', order: 22,
    items: [
      { name: 'Turkey Slices', emoji: '🍖' }, { name: 'Ham Slices', emoji: '🍖' },
      { name: 'Salami', emoji: '🍖' }, { name: 'Pepperoni', emoji: '🍕' },
      { name: 'Roast Beef', emoji: '🥩' }, { name: 'Pastrami', emoji: '🥩' },
      { name: 'Bologna', emoji: '🍖' }, { name: 'Swiss Cheese', emoji: '🧀' },
      { name: 'Provolone', emoji: '🧀' }, { name: 'Chicken Strips', emoji: '🍗' },
      { name: 'Smoked Salmon', emoji: '🐟' }, { name: 'Hummus', emoji: '🫙' },
      { name: 'Coleslaw', emoji: '🥗' }, { name: 'Potato Salad', emoji: '🥗' },
    ],
  },
  {
    id: 'cat-other', label: 'Other', icon: 'shopping_bag', order: 23,
    items: [
      { name: 'Cooking Wine', emoji: '🍷' }, { name: 'Baking Powder', emoji: '🫙' },
      { name: 'Baking Soda', emoji: '🫙' }, { name: 'Yeast', emoji: '🌾' },
      { name: 'Gelatin', emoji: '🫙' }, { name: 'Vanilla Extract', emoji: '🫙' },
      { name: 'Food Coloring', emoji: '🎨' }, { name: 'Cocoa Powder', emoji: '🍫' },
      { name: 'Powdered Sugar', emoji: '🍬' }, { name: 'Brown Sugar', emoji: '🍯' },
      { name: 'White Sugar', emoji: '🍬' }, { name: 'Aluminum Foil', emoji: '🪙' },
      { name: 'Plastic Wrap', emoji: '🪙' }, { name: 'Parchment Paper', emoji: '📄' },
      { name: 'Zip Lock Bags', emoji: '🛍️' }, { name: 'Toothpicks', emoji: '🪥' },
    ],
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
  // Case-insensitive label match
  const doc = await Category.findOne({ label: { $regex: `^${label}$`, $options: 'i' } });
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
};
