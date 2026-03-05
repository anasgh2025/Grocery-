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
    id: 'cat-arabic-demo',
    label: 'منتجات عربية',
    label_ar: 'منتجات عربية',
    icon: 'star',
    order: 100,
    items: [
      { name: 'تمر', name_ar: 'تمر', emoji: '🌴' },
      { name: 'طحينة', name_ar: 'طحينة', emoji: '🥄' },
      { name: 'حمص', name_ar: 'حمص', emoji: '🫙' },
      { name: 'لبنة', name_ar: 'لبنة', emoji: '🥛' },
      { name: 'زعتر', name_ar: 'زعتر', emoji: '🌿' },
    ],
  },
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
    id: 'cat-vegetables', label: 'Vegetables', label_ar: 'خضروات', icon: 'eco', order: 1,
    items: [
      { name: 'Carrot', name_ar: 'جزر', emoji: '🥕' },
      { name: 'Broccoli', name_ar: 'بروكلي', emoji: '🥦' },
      { name: 'Spinach', name_ar: 'سبانخ', emoji: '🥬' },
      { name: 'Tomato', name_ar: 'طماطم', emoji: '🍅' },
      { name: 'Cucumber', name_ar: 'خيار', emoji: '🥒' },
      { name: 'Lettuce', name_ar: 'خس', emoji: '🥬' },
      { name: 'Onion', name_ar: 'بصل', emoji: '🧅' },
      { name: 'Garlic', name_ar: 'ثوم', emoji: '🧄' },
      { name: 'Potato', name_ar: 'بطاطس', emoji: '🥔' },
      { name: 'Sweet Potato', name_ar: 'بطاطا حلوة', emoji: '🍠' },
      { name: 'Bell Pepper', name_ar: 'فلفل رومي', emoji: '🫑' },
      { name: 'Corn', name_ar: 'ذرة', emoji: '🌽' },
      { name: 'Mushroom', name_ar: 'فطر', emoji: '🍄' },
      { name: 'Celery', name_ar: 'كرفس', emoji: '🥬' },
      { name: 'Zucchini', name_ar: 'كوسا', emoji: '🥒' },
      { name: 'Eggplant', name_ar: 'باذنجان', emoji: '🍆' },
      { name: 'Cauliflower', name_ar: 'قرنبيط', emoji: '🥦' },
      { name: 'Beetroot', name_ar: 'شمندر', emoji: '🫐' },
      { name: 'Asparagus', name_ar: 'هليون', emoji: '🌿' },
      { name: 'Peas', name_ar: 'بازلاء', emoji: '🟢' },
    ],
  },
  {
    id: 'cat-meat', label: 'Meat', label_ar: 'لحوم', icon: 'set_meal', order: 2,
    items: [
      { name: 'Chicken Breast', name_ar: 'صدر دجاج', emoji: '🍗' },
      { name: 'Chicken Thighs', name_ar: 'ورك دجاج', emoji: '🍗' },
      { name: 'Ground Beef', name_ar: 'لحم بقري مفروم', emoji: '🥩' },
      { name: 'Beef Steak', name_ar: 'شريحة لحم بقري', emoji: '🥩' },
      { name: 'Lamb Chops', name_ar: 'ريش غنم', emoji: '🥩' },
      { name: 'Pork Chops', name_ar: 'ريش خنزير', emoji: '🥩' },
      { name: 'Bacon', name_ar: 'لحم مقدد', emoji: '🥓' },
      { name: 'Sausage', name_ar: 'نقانق', emoji: '🌭' },
      { name: 'Turkey', name_ar: 'ديك رومي', emoji: '🦃' },
      { name: 'Veal', name_ar: 'عجل', emoji: '🥩' },
      { name: 'Duck', name_ar: 'بط', emoji: '🦆' },
      { name: 'Ribs', name_ar: 'ضلوع', emoji: '🥩' },
      { name: 'Minced Lamb', name_ar: 'لحم غنم مفروم', emoji: '🥩' },
      { name: 'Hot Dogs', name_ar: 'هوت دوج', emoji: '🌭' },
      { name: 'Deli Ham', name_ar: 'لحم خنزير مدخن', emoji: '🥩' },
      { name: 'Salami', name_ar: 'سلامي', emoji: '🥩' },
    ],
  },
  {
    id: 'cat-seafood', label: 'Seafood', label_ar: 'مأكولات بحرية', icon: 'water', order: 3,
    items: [
      { name: 'Salmon', name_ar: 'سلمون', emoji: '🐟' },
      { name: 'Tuna', name_ar: 'تونة', emoji: '🐟' },
      { name: 'Shrimp', name_ar: 'جمبري', emoji: '🍤' },
      { name: 'Crab', name_ar: 'سلطعون', emoji: '🦀' },
      { name: 'Lobster', name_ar: 'كركند', emoji: '🦞' },
      { name: 'Sardines', name_ar: 'سردين', emoji: '🐟' },
      { name: 'Cod', name_ar: 'سمك القد', emoji: '🐟' },
      { name: 'Tilapia', name_ar: 'بلطي', emoji: '🐠' },
      { name: 'Oysters', name_ar: 'محار', emoji: '🦪' },
      { name: 'Mussels', name_ar: 'بلح البحر', emoji: '🦪' },
      { name: 'Clams', name_ar: 'محار صدفي', emoji: '🦪' },
      { name: 'Squid', name_ar: 'حبار', emoji: '🦑' },
      { name: 'Octopus', name_ar: 'أخطبوط', emoji: '🐙' },
      { name: 'Scallops', name_ar: 'إسكالوب', emoji: '🍤' },
      { name: 'Mackerel', name_ar: 'ماكريل', emoji: '🐟' },
      { name: 'Anchovies', name_ar: 'أنشوجة', emoji: '🐟' },
    ],
  },
  {
    id: 'cat-dairy', label: 'Dairy', label_ar: 'منتجات الألبان', icon: 'egg_alt', order: 4,
    items: [
      { name: 'Milk', name_ar: 'حليب', emoji: '🥛' },
      { name: 'Eggs', name_ar: 'بيض', emoji: '🥚' },
      { name: 'Butter', name_ar: 'زبدة', emoji: '🧈' },
      { name: 'Cheddar Cheese', name_ar: 'جبنة شيدر', emoji: '🧀' },
      { name: 'Mozzarella', name_ar: 'موزاريلا', emoji: '🧀' },
      { name: 'Cream Cheese', name_ar: 'جبنة كريمية', emoji: '🧀' },
      { name: 'Yogurt', name_ar: 'زبادي', emoji: '🥛' },
      { name: 'Sour Cream', name_ar: 'كريمة حامضة', emoji: '🥛' },
      { name: 'Heavy Cream', name_ar: 'كريمة ثقيلة', emoji: '🥛' },
      { name: 'Parmesan', name_ar: 'بارميزان', emoji: '🧀' },
      { name: 'Feta Cheese', name_ar: 'جبنة فيتا', emoji: '🧀' },
      { name: 'Ricotta', name_ar: 'ريكوتا', emoji: '🧀' },
      { name: 'Whipped Cream', name_ar: 'كريمة مخفوقة', emoji: '🥛' },
      { name: 'Condensed Milk', name_ar: 'حليب مكثف', emoji: '🥛' },
      { name: 'Kefir', name_ar: 'كفير', emoji: '🥛' },
    ],
  },
  {
    id: 'cat-bakery', label: 'Bakery', label_ar: 'مخبوزات', icon: 'bakery_dining', order: 5,
    items: [
      { name: 'White Bread', name_ar: 'خبز أبيض', emoji: '🍞' },
      { name: 'Whole Wheat Bread', name_ar: 'خبز قمح كامل', emoji: '🍞' },
      { name: 'Baguette', name_ar: 'باجيت', emoji: '🥖' },
      { name: 'Croissant', name_ar: 'كرواسون', emoji: '🥐' },
      { name: 'Bagel', name_ar: 'بيغل', emoji: '🥯' },
      { name: 'Pita Bread', name_ar: 'خبز بيتا', emoji: '🫓' },
      { name: 'Tortillas', name_ar: 'تورتيلا', emoji: '🫓' },
      { name: 'Muffins', name_ar: 'مافن', emoji: '🧁' },
      { name: 'Dinner Rolls', name_ar: 'لفائف عشاء', emoji: '🍞' },
      { name: 'Sourdough', name_ar: 'خبز العجين المخمر', emoji: '🍞' },
      { name: 'Rye Bread', name_ar: 'خبز الجاودار', emoji: '🍞' },
      { name: 'Brioche', name_ar: 'بريوش', emoji: '🍞' },
      { name: 'Pretzel', name_ar: 'بريتزل', emoji: '🥨' },
      { name: 'Donuts', name_ar: 'دونات', emoji: '🍩' },
      { name: 'Waffles', name_ar: 'وافِل', emoji: '🧇' },
      { name: 'Pancake Mix', name_ar: 'خليط فطائر', emoji: '🥞' },
    ],
  },
  {
    id: 'cat-beverages', label: 'Beverages', label_ar: 'مشروبات', icon: 'local_drink', order: 6,
    items: [
      { name: 'Water', name_ar: 'ماء', emoji: '💧' },
      { name: 'Orange Juice', name_ar: 'عصير برتقال', emoji: '🍊' },
      { name: 'Apple Juice', name_ar: 'عصير تفاح', emoji: '🍎' },
      { name: 'Coffee', name_ar: 'قهوة', emoji: '☕' },
      { name: 'Tea', name_ar: 'شاي', emoji: '🍵' },
      { name: 'Soda', name_ar: 'مشروب غازي', emoji: '🥤' },
      { name: 'Energy Drink', name_ar: 'مشروب طاقة', emoji: '⚡' },
      { name: 'Milk', name_ar: 'حليب', emoji: '🥛' },
      { name: 'Sparkling Water', name_ar: 'ماء فوار', emoji: '💦' },
      { name: 'Lemonade', name_ar: 'ليمونادة', emoji: '🍋' },
      { name: 'Coconut Water', name_ar: 'ماء جوز الهند', emoji: '🥥' },
      { name: 'Sports Drink', name_ar: 'مشروب رياضي', emoji: '🏃' },
      { name: 'Green Tea', name_ar: 'شاي أخضر', emoji: '🍵' },
      { name: 'Hot Chocolate', name_ar: 'شوكولاتة ساخنة', emoji: '☕' },
      { name: 'Wine', name_ar: 'نبيذ', emoji: '🍷' },
      { name: 'Beer', name_ar: 'بيرة', emoji: '🍺' },
      { name: 'Smoothie', name_ar: 'سموذي', emoji: '🥤' },
      { name: 'Almond Milk', name_ar: 'حليب لوز', emoji: '🥛' },
    ],
  },
  {
    id: 'cat-snacks', label: 'Snacks', label_ar: 'وجبات خفيفة', icon: 'cookie', order: 7,
    items: [
      { name: 'Chips', name_ar: 'رقائق', emoji: '🥔' },
      { name: 'Popcorn', name_ar: 'فشار', emoji: '🍿' },
      { name: 'Crackers', name_ar: 'مقرمشات', emoji: '🫙' },
      { name: 'Pretzels', name_ar: 'بريتزل', emoji: '🥨' },
      { name: 'Nuts Mix', name_ar: 'خليط مكسرات', emoji: '🥜' },
      { name: 'Almonds', name_ar: 'لوز', emoji: '🥜' },
      { name: 'Cashews', name_ar: 'كاجو', emoji: '🥜' },
      { name: 'Granola Bar', name_ar: 'لوح جرانولا', emoji: '🍫' },
      { name: 'Rice Cakes', name_ar: 'كعك الأرز', emoji: '🍙' },
      { name: 'Dried Fruit', name_ar: 'فاكهة مجففة', emoji: '🍇' },
      { name: 'Fruit Snacks', name_ar: 'وجبات فواكه', emoji: '🍬' },
      { name: 'Peanut Butter', name_ar: 'زبدة الفول السوداني', emoji: '🥜' },
      { name: 'Hummus', name_ar: 'حمص', emoji: '🫙' },
      { name: 'Cheese Sticks', name_ar: 'أعواد جبن', emoji: '🧀' },
      { name: 'Protein Bar', name_ar: 'لوح بروتين', emoji: '💪' },
      { name: 'Trail Mix', name_ar: 'خليط درب', emoji: '🌰' },
    ],
  },
  {
    id: 'cat-frozen', label: 'Frozen', label_ar: 'مجمدات', icon: 'ac_unit', order: 8,
    items: [
      { name: 'Ice Cream', name_ar: 'آيس كريم', emoji: '🍦' },
      { name: 'Frozen Pizza', name_ar: 'بيتزا مجمدة', emoji: '🍕' },
      { name: 'Frozen Fries', name_ar: 'بطاطس مقلية مجمدة', emoji: '🍟' },
      { name: 'Frozen Peas', name_ar: 'بازلاء مجمدة', emoji: '🟢' },
      { name: 'Frozen Corn', name_ar: 'ذرة مجمدة', emoji: '🌽' },
      { name: 'Frozen Berries', name_ar: 'توت مجمد', emoji: '🫐' },
      { name: 'Frozen Shrimp', name_ar: 'جمبري مجمد', emoji: '🍤' },
      { name: 'Frozen Chicken', name_ar: 'دجاج مجمد', emoji: '🍗' },
      { name: 'Frozen Waffles', name_ar: 'وافل مجمد', emoji: '🧇' },
      { name: 'Sorbet', name_ar: 'سوربيه', emoji: '🍧' },
      { name: 'Frozen Burrito', name_ar: 'بوريتو مجمد', emoji: '🌯' },
      { name: 'Frozen Lasagna', name_ar: 'لازانيا مجمدة', emoji: '🍝' },
      { name: 'Frozen Fish', name_ar: 'سمك مجمد', emoji: '🐟' },
      { name: 'Popsicles', name_ar: 'مصاصات مثلجة', emoji: '🧊' },
    ],
  },
  {
    id: 'cat-grains', label: 'Grains', label_ar: 'حبوب', icon: 'grain', order: 9,
    items: [
      { name: 'White Rice', name_ar: 'أرز أبيض', emoji: '🍚' },
      { name: 'Brown Rice', name_ar: 'أرز بني', emoji: '🍚' },
      { name: 'Oats', name_ar: 'شوفان', emoji: '🌾' },
      { name: 'Quinoa', name_ar: 'كينوا', emoji: '🌾' },
      { name: 'Barley', name_ar: 'شعير', emoji: '🌾' },
      { name: 'Bulgur', name_ar: 'برغل', emoji: '🌾' },
      { name: 'Couscous', name_ar: 'كسكس', emoji: '🌾' },
      { name: 'Corn Meal', name_ar: 'دقيق الذرة', emoji: '🌽' },
      { name: 'Breadcrumbs', name_ar: 'فتات الخبز', emoji: '🍞' },
      { name: 'Flour', name_ar: 'طحين', emoji: '🌾' },
      { name: 'Cornstarch', name_ar: 'نشا الذرة', emoji: '🌽' },
      { name: 'Wheat Bran', name_ar: 'نخالة القمح', emoji: '🌾' },
    ],
  },
  {
    id: 'cat-condiments', label: 'Condiments', label_ar: 'صلصات وتوابل', icon: 'blender', order: 10,
    items: [
      { name: 'Ketchup', name_ar: 'كاتشب', emoji: '🍅' },
      { name: 'Mustard', name_ar: 'خردل', emoji: '💛' },
      { name: 'Mayonnaise', name_ar: 'مايونيز', emoji: '🫙' },
      { name: 'Hot Sauce', name_ar: 'صلصة حارة', emoji: '🌶️' },
      { name: 'Soy Sauce', name_ar: 'صلصة الصويا', emoji: '🫙' },
      { name: 'Barbecue Sauce', name_ar: 'صلصة باربكيو', emoji: '🍖' },
      { name: 'Ranch Dressing', name_ar: 'صلصة رانش', emoji: '🫙' },
      { name: 'Honey Mustard', name_ar: 'خردل بالعسل', emoji: '🍯' },
      { name: 'Salsa', name_ar: 'صلصة سالسا', emoji: '🍅' },
      { name: 'Guacamole', name_ar: 'جواكامولي', emoji: '🥑' },
      { name: 'Relish', name_ar: 'ريليش', emoji: '🫙' },
      { name: 'Sriracha', name_ar: 'سريراتشا', emoji: '🌶️' },
      { name: 'Worcestershire', name_ar: 'ورشستر', emoji: '🫙' },
      { name: 'Vinegar', name_ar: 'خل', emoji: '🫙' },
      { name: 'Olive Tapenade', name_ar: 'تابيناد الزيتون', emoji: '🫒' },
    ],
  },
  {
    id: 'cat-canned-goods', label: 'Canned Goods', label_ar: 'معلبات', icon: 'inventory_2', order: 11,
    items: [
      { name: 'Canned Tomatoes', name_ar: 'طماطم معلبة', emoji: '🥫' },
      { name: 'Canned Tuna', name_ar: 'تونة معلبة', emoji: '🥫' },
      { name: 'Canned Beans', name_ar: 'فاصوليا معلبة', emoji: '🥫' },
      { name: 'Canned Corn', name_ar: 'ذرة معلبة', emoji: '🥫' },
      { name: 'Canned Peas', name_ar: 'بازلاء معلبة', emoji: '🥫' },
      { name: 'Canned Soup', name_ar: 'شوربة معلبة', emoji: '🥫' },
      { name: 'Tomato Paste', name_ar: 'معجون طماطم', emoji: '🥫' },
      { name: 'Coconut Milk', name_ar: 'حليب جوز الهند', emoji: '🥫' },
      { name: 'Chickpeas', name_ar: 'حمص', emoji: '🥫' },
      { name: 'Kidney Beans', name_ar: 'فاصوليا حمراء', emoji: '🥫' },
      { name: 'Lentils', name_ar: 'عدس', emoji: '🥫' },
      { name: 'Canned Peaches', name_ar: 'خوخ معلب', emoji: '🥫' },
      { name: 'Canned Pineapple', name_ar: 'أناناس معلب', emoji: '🥫' },
      { name: 'Sardines', name_ar: 'سردين معلب', emoji: '🥫' },
      { name: 'Canned Mushrooms', name_ar: 'فطر معلب', emoji: '🥫' },
    ],
  },
  {
    id: 'cat-spices', label: 'Spices', label_ar: 'بهارات', icon: 'spa', order: 12,
    items: [
      { name: 'Salt', name_ar: 'ملح', emoji: '🧂' },
      { name: 'Black Pepper', name_ar: 'فلفل أسود', emoji: '⚫' },
      { name: 'Cumin', name_ar: 'كمون', emoji: '🌿' },
      { name: 'Paprika', name_ar: 'بابريكا', emoji: '🌶️' },
      { name: 'Turmeric', name_ar: 'كركم', emoji: '🟡' },
      { name: 'Cinnamon', name_ar: 'قرفة', emoji: '🌿' },
      { name: 'Oregano', name_ar: 'أوريجانو', emoji: '🌿' },
      { name: 'Basil', name_ar: 'ريحان', emoji: '🌿' },
      { name: 'Thyme', name_ar: 'زعتر', emoji: '🌿' },
      { name: 'Bay Leaves', name_ar: 'ورق غار', emoji: '🍃' },
      { name: 'Chili Flakes', name_ar: 'رقائق الفلفل الحار', emoji: '🌶️' },
      { name: 'Garlic Powder', name_ar: 'بودرة ثوم', emoji: '🧄' },
      { name: 'Onion Powder', name_ar: 'بودرة بصل', emoji: '🧅' },
      { name: 'Ginger', name_ar: 'زنجبيل', emoji: '🫚' },
      { name: 'Cardamom', name_ar: 'هيل', emoji: '🌿' },
      { name: 'Nutmeg', name_ar: 'جوزة الطيب', emoji: '🌰' },
      { name: 'Coriander', name_ar: 'كزبرة', emoji: '🌿' },
      { name: 'Cloves', name_ar: 'قرنفل', emoji: '🌿' },
    ],
  },
  {
    id: 'cat-oils-fats', label: 'Oils & Fats', label_ar: 'زيوت ودهون', icon: 'opacity', order: 13,
    items: [
      { name: 'Olive Oil', name_ar: 'زيت زيتون', emoji: '🫒' },
      { name: 'Vegetable Oil', name_ar: 'زيت نباتي', emoji: '🫙' },
      { name: 'Coconut Oil', name_ar: 'زيت جوز الهند', emoji: '🥥' },
      { name: 'Butter', name_ar: 'زبدة', emoji: '🧈' },
      { name: 'Margarine', name_ar: 'مارجرين', emoji: '🧈' },
      { name: 'Canola Oil', name_ar: 'زيت الكانولا', emoji: '🫙' },
      { name: 'Sesame Oil', name_ar: 'زيت السمسم', emoji: '🫙' },
      { name: 'Avocado Oil', name_ar: 'زيت الأفوكادو', emoji: '🥑' },
      { name: 'Ghee', name_ar: 'سمن', emoji: '🧈' },
      { name: 'Lard', name_ar: 'شحم', emoji: '🫙' },
      { name: 'Sunflower Oil', name_ar: 'زيت دوار الشمس', emoji: '🌻' },
    ],
  },
  {
    id: 'cat-sweets', label: 'Sweets', label_ar: 'حلويات', icon: 'cake', order: 14,
    items: [
      { name: 'Chocolate Bar', name_ar: 'لوح شوكولاتة', emoji: '🍫' },
      { name: 'Candy', name_ar: 'حلوى', emoji: '🍬' },
      { name: 'Gummy Bears', name_ar: 'دببة جيلاتين', emoji: '🐻' },
      { name: 'Lollipop', name_ar: 'مصاصة', emoji: '🍭' },
      { name: 'Marshmallows', name_ar: 'مارشميلو', emoji: '☁️' },
      { name: 'Cookies', name_ar: 'كوكيز', emoji: '🍪' },
      { name: 'Cake', name_ar: 'كيك', emoji: '🎂' },
      { name: 'Brownie', name_ar: 'براوني', emoji: '🍫' },
      { name: 'Honey', name_ar: 'عسل', emoji: '🍯' },
      { name: 'Jam', name_ar: 'مربى', emoji: '🍓' },
      { name: 'Maple Syrup', name_ar: 'شراب القيقب', emoji: '🍁' },
      { name: 'Nutella', name_ar: 'نوتيلا', emoji: '🍫' },
      { name: 'Ice Cream', name_ar: 'آيس كريم', emoji: '🍨' },
      { name: 'Pudding', name_ar: 'بودينغ', emoji: '🍮' },
      { name: 'Caramel', name_ar: 'كراميل', emoji: '🍯' },
      { name: 'Jelly', name_ar: 'جيلي', emoji: '🫙' },
    ],
  },
  {
    id: 'cat-baby-food', label: 'Baby Food', label_ar: 'طعام أطفال', icon: 'child_care', order: 15,
    items: [
      { name: 'Baby Formula', name_ar: 'حليب أطفال', emoji: '🍼' },
      { name: 'Pureed Veggies', name_ar: 'خضار مهروسة', emoji: '🥣' },
      { name: 'Pureed Fruits', name_ar: 'فاكهة مهروسة', emoji: '🥣' },
      { name: 'Baby Cereal', name_ar: 'حبوب أطفال', emoji: '🌾' },
      { name: 'Teething Snacks', name_ar: 'وجبات تسنين', emoji: '🍪' },
      { name: 'Baby Yogurt', name_ar: 'زبادي أطفال', emoji: '🥛' },
      { name: 'Baby Juice', name_ar: 'عصير أطفال', emoji: '🧃' },
      { name: 'Rice Puffs', name_ar: 'أرز منتفخ', emoji: '🌾' },
      { name: 'Baby Pouches', name_ar: 'أكياس طعام أطفال', emoji: '🥣' },
      { name: 'Baby Water', name_ar: 'ماء أطفال', emoji: '💧' },
    ],
  },
  {
    id: 'cat-health', label: 'Health', label_ar: 'صحة', icon: 'health_and_safety', order: 16,
    items: [
      { name: 'Protein Powder', name_ar: 'مسحوق بروتين', emoji: '💪' },
      { name: 'Vitamins', name_ar: 'فيتامينات', emoji: '💊' },
      { name: 'Fiber Supplement', name_ar: 'مكمل ألياف', emoji: '🌿' },
      { name: 'Probiotics', name_ar: 'بروبيوتيك', emoji: '🦠' },
      { name: 'Fish Oil', name_ar: 'زيت السمك', emoji: '🐟' },
      { name: 'Collagen', name_ar: 'كولاجين', emoji: '✨' },
      { name: 'Multivitamin', name_ar: 'فيتامينات متعددة', emoji: '💊' },
      { name: 'Chia Seeds', name_ar: 'بذور الشيا', emoji: '🌱' },
      { name: 'Flax Seeds', name_ar: 'بذور الكتان', emoji: '🌱' },
      { name: 'Whey Protein', name_ar: 'بروتين مصل اللبن', emoji: '💪' },
      { name: 'Herbal Tea', name_ar: 'شاي أعشاب', emoji: '🍵' },
      { name: 'Apple Cider Vinegar', name_ar: 'خل التفاح', emoji: '🍎' },
    ],
  },
  {
    id: 'cat-cleaning', label: 'Cleaning', label_ar: 'تنظيف', icon: 'cleaning_services', order: 17,
    items: [
      { name: 'Dish Soap', name_ar: 'صابون أطباق', emoji: '🧴' },
      { name: 'Laundry Detergent', name_ar: 'منظف غسيل', emoji: '🧺' },
      { name: 'All-Purpose Spray', name_ar: 'بخاخ متعدد الأغراض', emoji: '🧹' },
      { name: 'Bleach', name_ar: 'مبيض', emoji: '🫙' },
      { name: 'Floor Cleaner', name_ar: 'منظف أرضيات', emoji: '🧹' },
      { name: 'Toilet Cleaner', name_ar: 'منظف مرحاض', emoji: '🚽' },
      { name: 'Glass Cleaner', name_ar: 'منظف زجاج', emoji: '🪟' },
      { name: 'Sponges', name_ar: 'إسفنجات', emoji: '🧽' },
      { name: 'Paper Towels', name_ar: 'مناديل ورقية', emoji: '🧻' },
      { name: 'Trash Bags', name_ar: 'أكياس قمامة', emoji: '🗑️' },
      { name: 'Fabric Softener', name_ar: 'منعم أقمشة', emoji: '🌸' },
      { name: 'Dryer Sheets', name_ar: 'ورق تجفيف', emoji: '🌸' },
      { name: 'Mop', name_ar: 'ممسحة', emoji: '🧹' },
      { name: 'Broom', name_ar: 'مكنسة', emoji: '🧹' },
    ],
  },
  {
    id: 'cat-personal-care', label: 'Personal Care', label_ar: 'العناية الشخصية', icon: 'face', order: 18,
    items: [
      { name: 'Shampoo', name_ar: 'شامبو', emoji: '🧴' },
      { name: 'Conditioner', name_ar: 'بلسم', emoji: '🧴' },
      { name: 'Body Wash', name_ar: 'غسول جسم', emoji: '🧼' },
      { name: 'Soap Bar', name_ar: 'صابون قالب', emoji: '🧼' },
      { name: 'Toothpaste', name_ar: 'معجون أسنان', emoji: '🦷' },
      { name: 'Toothbrush', name_ar: 'فرشاة أسنان', emoji: '🪥' },
      { name: 'Deodorant', name_ar: 'مزيل عرق', emoji: '✨' },
      { name: 'Moisturizer', name_ar: 'مرطب', emoji: '🧴' },
      { name: 'Sunscreen', name_ar: 'واقي شمس', emoji: '☀️' },
      { name: 'Razor', name_ar: 'شفرة حلاقة', emoji: '🪒' },
      { name: 'Shaving Cream', name_ar: 'كريم حلاقة', emoji: '🧴' },
      { name: 'Facial Cleanser', name_ar: 'منظف وجه', emoji: '💆' },
      { name: 'Lip Balm', name_ar: 'مرطب شفاه', emoji: '💋' },
      { name: 'Hand Sanitizer', name_ar: 'معقم يدين', emoji: '🤲' },
      { name: 'Tissue', name_ar: 'مناديل', emoji: '🧻' },
      { name: 'Cotton Pads', name_ar: 'قطن', emoji: '☁️' },
    ],
  },
  {
    id: 'cat-pet-food', label: 'Pet Food', label_ar: 'طعام الحيوانات الأليفة', icon: 'pets', order: 19,
    items: [
      { name: 'Dog Food (Dry)', name_ar: 'طعام كلاب (جاف)', emoji: '🐕' },
      { name: 'Dog Food (Wet)', name_ar: 'طعام كلاب (رطب)', emoji: '🐕' },
      { name: 'Cat Food (Dry)', name_ar: 'طعام قطط (جاف)', emoji: '🐈' },
      { name: 'Cat Food (Wet)', name_ar: 'طعام قطط (رطب)', emoji: '🐈' },
      { name: 'Dog Treats', name_ar: 'مكافآت كلاب', emoji: '🦴' },
      { name: 'Cat Treats', name_ar: 'مكافآت قطط', emoji: '🐾' },
      { name: 'Bird Seed', name_ar: 'بذور طيور', emoji: '🐦' },
      { name: 'Fish Food', name_ar: 'طعام أسماك', emoji: '🐠' },
      { name: 'Rabbit Pellets', name_ar: 'كريات أرانب', emoji: '🐇' },
      { name: 'Hamster Food', name_ar: 'طعام هامستر', emoji: '🐹' },
      { name: 'Pet Milk', name_ar: 'حليب حيوانات أليفة', emoji: '🥛' },
      { name: 'Dental Chews', name_ar: 'مضغيات أسنان', emoji: '🦷' },
    ],
  },
  {
    id: 'cat-breakfast', label: 'Breakfast', label_ar: 'فطور', icon: 'free_breakfast', order: 20,
    items: [
      { name: 'Cereal', name_ar: 'حبوب الإفطار', emoji: '🥣' },
      { name: 'Oatmeal', name_ar: 'دقيق الشوفان', emoji: '🌾' },
      { name: 'Granola', name_ar: 'جرانولا', emoji: '🌾' },
      { name: 'Pancake Mix', name_ar: 'خليط فطائر', emoji: '🥞' },
      { name: 'Waffle Mix', name_ar: 'خليط وافل', emoji: '🧇' },
      { name: 'Orange Juice', name_ar: 'عصير برتقال', emoji: '🍊' },
      { name: 'Maple Syrup', name_ar: 'شراب القيقب', emoji: '🍁' },
      { name: 'Jam', name_ar: 'مربى', emoji: '🍓' },
      { name: 'Peanut Butter', name_ar: 'زبدة الفول السوداني', emoji: '🥜' },
      { name: 'Yogurt', name_ar: 'زبادي', emoji: '🥛' },
      { name: 'Eggs', name_ar: 'بيض', emoji: '🥚' },
      { name: 'Bacon', name_ar: 'لحم مقدد', emoji: '🥓' },
      { name: 'Bagel', name_ar: 'بيغل', emoji: '🥯' },
      { name: 'English Muffin', name_ar: 'مافن إنجليزي', emoji: '🍞' },
      { name: 'Breakfast Bar', name_ar: 'لوح فطور', emoji: '🍫' },
    ],
  },
  {
    id: 'cat-pasta-rice', label: 'Pasta & Rice', label_ar: 'مكرونة وأرز', icon: 'rice_bowl', order: 21,
    items: [
      { name: 'Spaghetti', name_ar: 'سباغيتي', emoji: '🍝' },
      { name: 'Penne', name_ar: 'بيني', emoji: '🍝' },
      { name: 'Fusilli', name_ar: 'فوسيلي', emoji: '🍝' },
      { name: 'Fettuccine', name_ar: 'فيتوتشيني', emoji: '🍝' },
      { name: 'Lasagna Sheets', name_ar: 'رقائق لازانيا', emoji: '🍝' },
      { name: 'Macaroni', name_ar: 'مكرونة', emoji: '🧀' },
      { name: 'White Rice', name_ar: 'أرز أبيض', emoji: '🍚' },
      { name: 'Brown Rice', name_ar: 'أرز بني', emoji: '🍚' },
      { name: 'Basmati Rice', name_ar: 'أرز بسمتي', emoji: '🍚' },
      { name: 'Jasmine Rice', name_ar: 'أرز ياسمين', emoji: '🍚' },
      { name: 'Arborio Rice', name_ar: 'أرز أربوريو', emoji: '🍚' },
      { name: 'Noodles', name_ar: 'نودلز', emoji: '🍜' },
      { name: 'Rice Noodles', name_ar: 'نودلز الأرز', emoji: '🍜' },
      { name: 'Vermicelli', name_ar: 'شعرية', emoji: '🍜' },
      { name: 'Egg Noodles', name_ar: 'نودلز البيض', emoji: '🍜' },
    ],
  },
  {
    id: 'cat-deli', label: 'Deli', label_ar: 'لحوم باردة', icon: 'lunch_dining', order: 22,
    items: [
      { name: 'Turkey Slices', name_ar: 'شرائح ديك رومي', emoji: '🍖' },
      { name: 'Ham Slices', name_ar: 'شرائح لحم خنزير', emoji: '🍖' },
      { name: 'Salami', name_ar: 'سلامي', emoji: '🍖' },
      { name: 'Pepperoni', name_ar: 'بيبروني', emoji: '🍕' },
      { name: 'Roast Beef', name_ar: 'لحم بقري مشوي', emoji: '🥩' },
      { name: 'Pastrami', name_ar: 'بسترمة', emoji: '🥩' },
      { name: 'Bologna', name_ar: 'بولونيا', emoji: '🍖' },
      { name: 'Swiss Cheese', name_ar: 'جبنة سويسرية', emoji: '🧀' },
      { name: 'Provolone', name_ar: 'جبنة بروفولوني', emoji: '🧀' },
      { name: 'Chicken Strips', name_ar: 'شرائح دجاج', emoji: '🍗' },
      { name: 'Smoked Salmon', name_ar: 'سلمون مدخن', emoji: '🐟' },
      { name: 'Hummus', name_ar: 'حمص', emoji: '🫙' },
      { name: 'Coleslaw', name_ar: 'سلطة كولسلو', emoji: '🥗' },
      { name: 'Potato Salad', name_ar: 'سلطة بطاطس', emoji: '🥗' },
    ],
  },
  {
    id: 'cat-other', label: 'Other', label_ar: 'أخرى', icon: 'shopping_bag', order: 23,
    items: [
      { name: 'Cooking Wine', name_ar: 'نبيذ الطبخ', emoji: '🍷' },
      { name: 'Baking Powder', name_ar: 'بيكنج بودر', emoji: '🫙' },
      { name: 'Baking Soda', name_ar: 'بيكربونات الصوديوم', emoji: '🫙' },
      { name: 'Yeast', name_ar: 'خميرة', emoji: '🌾' },
      { name: 'Gelatin', name_ar: 'جيلاتين', emoji: '🫙' },
      { name: 'Vanilla Extract', name_ar: 'مستخلص الفانيليا', emoji: '🫙' },
      { name: 'Food Coloring', name_ar: 'ملون طعام', emoji: '🎨' },
      { name: 'Cocoa Powder', name_ar: 'كاكاو بودرة', emoji: '🍫' },
      { name: 'Powdered Sugar', name_ar: 'سكر بودرة', emoji: '🍬' },
      { name: 'Brown Sugar', name_ar: 'سكر بني', emoji: '🍯' },
      { name: 'White Sugar', name_ar: 'سكر أبيض', emoji: '🍬' },
      { name: 'Aluminum Foil', name_ar: 'ورق ألومنيوم', emoji: '🪙' },
      { name: 'Plastic Wrap', name_ar: 'غلاف بلاستيكي', emoji: '🪙' },
      { name: 'Parchment Paper', name_ar: 'ورق زبدة', emoji: '📄' },
      { name: 'Zip Lock Bags', name_ar: 'أكياس زيبلوك', emoji: '🛍️' },
      { name: 'Toothpicks', name_ar: 'عيدان أسنان', emoji: '🪥' },
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
};
