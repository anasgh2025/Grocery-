// Search for items by name (across all categories, case-insensitive, supports Arabic)
const searchItems = async (query, lang = 'en') => {
  const minLen = lang === 'ar' ? 2 : 3;
  if (!query || query.length < minLen) return [];
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
    { name: 'Green Apple', name_ar: 'تفاح أخضر', emoji: '🍏' },
    { name: 'Red Apple', name_ar: 'تفاح أحمر', emoji: '🍎' },

    { name: 'Banana', name_ar: 'موز', emoji: '🍌' },

    { name: 'Orange', name_ar: 'برتقال', emoji: '🍊' },
    { name: 'Mandarin', name_ar: 'يوسفي', emoji: '🍊' },
    { name: 'Clementine', name_ar: 'كلمنتينا', emoji: '🍊' },
    { name: 'Tangerine', name_ar: 'يوسفي', emoji: '🍊' },
    { name: 'Grapefruit', name_ar: 'جريب فروت', emoji: '🍊' },

    { name: 'Lemon', name_ar: 'ليمون', emoji: '🍋' },
    { name: 'Lime', name_ar: 'ليمون أخضر', emoji: '🍋' },

    { name: 'Mango', name_ar: 'مانجو', emoji: '🥭' },
    { name: 'Pakistani Mango', name_ar: 'مانجو باكستاني', emoji: '🥭' },
    { name: 'Indian Mango', name_ar: 'مانجو هندي', emoji: '🥭' },
    { name: 'Thai Mango', name_ar: 'مانجو تايلندي', emoji: '🥭' },

    { name: 'Pineapple', name_ar: 'أناناس', emoji: '🍍' },

    { name: 'Watermelon', name_ar: 'بطيخ', emoji: '🍉' },
    { name: 'Melon', name_ar: 'شمام', emoji: '🍈' },
    { name: 'Cantaloupe', name_ar: 'شمام', emoji: '🍈' },

    { name: 'Strawberry', name_ar: 'فراولة', emoji: '🍓' },
    { name: 'Blueberry', name_ar: 'توت أزرق', emoji: '🫐' },
    { name: 'Blackberry', name_ar: 'توت أسود', emoji: '🫐' },
    { name: 'Raspberry', name_ar: 'توت أحمر', emoji: '🫐' },

    { name: 'Grapes', name_ar: 'عنب', emoji: '🍇' },
    { name: 'Red Grapes', name_ar: 'عنب أحمر', emoji: '🍇' },
    { name: 'Green Grapes', name_ar: 'عنب أخضر', emoji: '🍇' },
    { name: 'Black Grapes', name_ar: 'عنب أسود', emoji: '🍇' },

    { name: 'Cherry', name_ar: 'كرز', emoji: '🍒' },

    { name: 'Peach', name_ar: 'خوخ', emoji: '🍑' },
    { name: 'Nectarine', name_ar: 'نكتارين', emoji: '🍑' },
    { name: 'Plum', name_ar: 'برقوق', emoji: '🍑' },

    { name: 'Pear', name_ar: 'كمثرى', emoji: '🍐' },

    { name: 'Kiwi', name_ar: 'كيوي', emoji: '🥝' },
    { name: 'Golden Kiwi', name_ar: 'كيوي ذهبي', emoji: '🥝' },

    { name: 'Avocado', name_ar: 'أفوكادو', emoji: '🥑' },

    { name: 'Pomegranate', name_ar: 'رمان', emoji: '🍎' },

    { name: 'Fig', name_ar: 'تين', emoji: '🍇' },
    { name: 'Fresh Fig', name_ar: 'تين طازج', emoji: '🍇' },

    { name: 'Dates', name_ar: 'تمر', emoji: '🌴' },
    { name: 'Medjool Dates', name_ar: 'تمر مجدول', emoji: '🌴' },
    { name: 'Ajwa Dates', name_ar: 'تمر عجوة', emoji: '🌴' },
    { name: 'Barhi Dates', name_ar: 'تمر برحي', emoji: '🌴' },

    { name: 'Guava', name_ar: 'جوافة', emoji: '🍈' },

    { name: 'Papaya', name_ar: 'بابايا', emoji: '🥭' },

    { name: 'Dragon Fruit', name_ar: 'فاكهة التنين', emoji: '🐉' },

    { name: 'Passion Fruit', name_ar: 'باشن فروت', emoji: '🥭' },

    { name: 'Lychee', name_ar: 'ليتشي', emoji: '🍒' },
    { name: 'Longan', name_ar: 'لونجان', emoji: '🍒' },

    { name: 'Persimmon', name_ar: 'كاكا', emoji: '🍊' },

    { name: 'Apricot', name_ar: 'مشمش', emoji: '🍑' },

    { name: 'Mulberry', name_ar: 'توت', emoji: '🫐' },

    { name: 'Star Fruit', name_ar: 'فاكهة النجمة', emoji: '⭐' },

    { name: 'Durian', name_ar: 'دوريان', emoji: '🟢' },

    { name: 'Jackfruit', name_ar: 'جاك فروت', emoji: '🍈' },

    { name: 'Coconut', name_ar: 'جوز الهند', emoji: '🥥' },

    { name: 'Sugarcane', name_ar: 'قصب السكر', emoji: '🌿' }
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
    { name: 'Cherry Tomato', name_ar: 'طماطم كرزية', emoji: '🍅' },

    { name: 'Potato', name_ar: 'بطاطس', emoji: '🥔' },
    { name: 'Sweet Potato', name_ar: 'بطاطا حلوة', emoji: '🍠' },

    { name: 'Onion', name_ar: 'بصل', emoji: '🧅' },
    { name: 'Red Onion', name_ar: 'بصل أحمر', emoji: '🧅' },
    { name: 'White Onion', name_ar: 'بصل أبيض', emoji: '🧅' },
    { name: 'Spring Onion', name_ar: 'بصل أخضر', emoji: '🌿' },

    { name: 'Garlic', name_ar: 'ثوم', emoji: '🧄' },

    { name: 'Carrot', name_ar: 'جزر', emoji: '🥕' },

    { name: 'Cucumber', name_ar: 'خيار', emoji: '🥒' },

    { name: 'Eggplant', name_ar: 'باذنجان', emoji: '🍆' },
    { name: 'Round Eggplant', name_ar: 'باذنجان دائري', emoji: '🍆' },
    { name: 'Long Eggplant', name_ar: 'باذنجان طويل', emoji: '🍆' },

    { name: 'Zucchini', name_ar: 'كوسة', emoji: '🥒' },

    { name: 'Bell Pepper', name_ar: 'فلفل رومي', emoji: '🫑' },
    { name: 'Red Bell Pepper', name_ar: 'فلفل أحمر', emoji: '🫑' },
    { name: 'Green Bell Pepper', name_ar: 'فلفل أخضر', emoji: '🫑' },
    { name: 'Yellow Bell Pepper', name_ar: 'فلفل أصفر', emoji: '🫑' },

    { name: 'Chili Pepper', name_ar: 'فلفل حار', emoji: '🌶️' },
    { name: 'Green Chili', name_ar: 'فلفل أخضر حار', emoji: '🌶️' },
    { name: 'Red Chili', name_ar: 'فلفل أحمر حار', emoji: '🌶️' },

    { name: 'Cabbage', name_ar: 'ملفوف', emoji: '🥬' },
    { name: 'Red Cabbage', name_ar: 'ملفوف أحمر', emoji: '🥬' },
    { name: 'Chinese Cabbage', name_ar: 'ملفوف صيني', emoji: '🥬' },

    { name: 'Lettuce', name_ar: 'خس', emoji: '🥬' },
    { name: 'Iceberg Lettuce', name_ar: 'خس آيسبرغ', emoji: '🥬' },
    { name: 'Romaine Lettuce', name_ar: 'خس روماني', emoji: '🥬' },

    { name: 'Spinach', name_ar: 'سبانخ', emoji: '🥬' },

    { name: 'Rocket Leaves', name_ar: 'جرجير', emoji: '🌿' },

    { name: 'Parsley', name_ar: 'بقدونس', emoji: '🌿' },
    { name: 'Coriander Leaves', name_ar: 'كزبرة خضراء', emoji: '🌿' },
    { name: 'Mint Leaves', name_ar: 'نعناع', emoji: '🌿' },
    { name: 'Dill', name_ar: 'شبت', emoji: '🌿' },

    { name: 'Broccoli', name_ar: 'بروكلي', emoji: '🥦' },
    { name: 'Cauliflower', name_ar: 'قرنبيط', emoji: '🥦' },

    { name: 'Green Beans', name_ar: 'فاصوليا خضراء', emoji: '🫛' },
    { name: 'French Beans', name_ar: 'فاصوليا فرنسية', emoji: '🫛' },

    { name: 'Peas', name_ar: 'بازلاء', emoji: '🫛' },

    { name: 'Corn', name_ar: 'ذرة', emoji: '🌽' },
    { name: 'Baby Corn', name_ar: 'ذرة صغيرة', emoji: '🌽' },

    { name: 'Mushroom', name_ar: 'فطر', emoji: '🍄' },
    { name: 'Button Mushroom', name_ar: 'فطر أبيض', emoji: '🍄' },
    { name: 'Portobello Mushroom', name_ar: 'فطر بورتوبيلو', emoji: '🍄' },
    { name: 'Shiitake Mushroom', name_ar: 'فطر شيتاكي', emoji: '🍄' },

    { name: 'Okra', name_ar: 'بامية', emoji: '🌿' },

    { name: 'Pumpkin', name_ar: 'قرع', emoji: '🎃' },

    { name: 'Beetroot', name_ar: 'شمندر', emoji: '🍠' },

    { name: 'Radish', name_ar: 'فجل', emoji: '🥕' },

    { name: 'Turnip', name_ar: 'لفت', emoji: '🥔' },

    { name: 'Bottle Gourd', name_ar: 'قرع أخضر', emoji: '🥒' },
    { name: 'Bitter Gourd', name_ar: 'قرع مر', emoji: '🥒' },

    { name: 'Drumstick', name_ar: 'مورينجا', emoji: '🌿' },

    { name: 'Taro Root', name_ar: 'قلقاس', emoji: '🥔' },

    { name: 'Cassava', name_ar: 'كسافا', emoji: '🥔' },

    { name: 'Sweet Corn Cob', name_ar: 'ذرة كاملة', emoji: '🌽' },

    { name: 'Leek', name_ar: 'كراث', emoji: '🌿' },

    { name: 'Celery', name_ar: 'كرفس', emoji: '🌿' },

    { name: 'Asparagus', name_ar: 'هليون', emoji: '🌿' },

    { name: 'Artichoke', name_ar: 'خرشوف', emoji: '🌿' },

    { name: 'Kale', name_ar: 'كرنب أجعد', emoji: '🥬' }
  ]
},

{
  id: 'cat-food-staples',
  label: 'Food Staples',
  label_ar: 'مواد غذائية أساسية',
  icon: 'grain',
  order: 3,
  items: [

    // 🍚 Rice
    { name: 'Basmati Rice', name_ar: 'أرز بسمتي', emoji: '🍚' },
    { name: 'Jasmine Rice', name_ar: 'أرز ياسمين', emoji: '🍚' },
    { name: 'White Rice', name_ar: 'أرز أبيض', emoji: '🍚' },
    { name: 'Brown Rice', name_ar: 'أرز بني', emoji: '🍚' },
    { name: 'Sella Rice', name_ar: 'أرز سيلا', emoji: '🍚' },
    { name: 'Sticky Rice', name_ar: 'أرز لزج', emoji: '🍚' },

    // 🌾 Grains
    { name: 'Oats', name_ar: 'شوفان', emoji: '🌾' },
    { name: 'Quinoa', name_ar: 'كينوا', emoji: '🌾' },
    { name: 'Barley', name_ar: 'شعير', emoji: '🌾' },
    { name: 'Millet', name_ar: 'دخن', emoji: '🌾' },
    { name: 'Couscous', name_ar: 'كسكس', emoji: '🌾' },
    { name: 'Bulgur', name_ar: 'برغل', emoji: '🌾' },

    // 🌾 Flour & Baking
    { name: 'All Purpose Flour', name_ar: 'طحين متعدد الاستخدامات', emoji: '🌾' },
    { name: 'Whole Wheat Flour', name_ar: 'طحين قمح كامل', emoji: '🌾' },
    { name: 'Self Raising Flour', name_ar: 'طحين ذاتي التخمير', emoji: '🌾' },
    { name: 'Corn Flour', name_ar: 'طحين ذرة', emoji: '🌽' },
    { name: 'Rice Flour', name_ar: 'طحين أرز', emoji: '🌾' },

    // 🫘 Pulses & Legumes
    { name: 'Lentils', name_ar: 'عدس', emoji: '🫘' },
    { name: 'Red Lentils', name_ar: 'عدس أحمر', emoji: '🫘' },
    { name: 'Green Lentils', name_ar: 'عدس أخضر', emoji: '🫘' },
    { name: 'Chickpeas', name_ar: 'حمص', emoji: '🫘' },
    { name: 'White Beans', name_ar: 'فاصوليا بيضاء', emoji: '🫘' },
    { name: 'Kidney Beans', name_ar: 'فاصوليا حمراء', emoji: '🫘' },
    { name: 'Black Beans', name_ar: 'فاصوليا سوداء', emoji: '🫘' },
    { name: 'Fava Beans', name_ar: 'فول', emoji: '🫘' },
    { name: 'Split Peas', name_ar: 'بازلاء مجروشة', emoji: '🫘' },

    // 🍝 Pasta & Noodles
    { name: 'Spaghetti', name_ar: 'سباغيتي', emoji: '🍝' },
    { name: 'Macaroni', name_ar: 'مكرونة قصيرة', emoji: '🍝' },
    { name: 'Penne Pasta', name_ar: 'مكرونة بيني', emoji: '🍝' },
    { name: 'Fusilli Pasta', name_ar: 'مكرونة فيوسيلي', emoji: '🍝' },
    { name: 'Lasagna Sheets', name_ar: 'شرائح لازانيا', emoji: '🍝' },
    { name: 'Instant Noodles', name_ar: 'نودلز فورية', emoji: '🍜' },

    // 🛢 Oils & Fats
    { name: 'Sunflower Oil', name_ar: 'زيت دوار الشمس', emoji: '🛢' },
    { name: 'Olive Oil', name_ar: 'زيت زيتون', emoji: '🛢' },
    { name: 'Corn Oil', name_ar: 'زيت ذرة', emoji: '🛢' },
    { name: 'Vegetable Oil', name_ar: 'زيت نباتي', emoji: '🛢' },
    { name: 'Coconut Oil', name_ar: 'زيت جوز الهند', emoji: '🥥' },
    { name: 'Ghee', name_ar: 'سمن', emoji: '🧈' },

    // 🍯 Sweeteners
    { name: 'Sugar', name_ar: 'سكر', emoji: '🍚' },
    { name: 'Brown Sugar', name_ar: 'سكر بني', emoji: '🍚' },
    { name: 'Powdered Sugar', name_ar: 'سكر بودرة', emoji: '🍚' },
    { name: 'Honey', name_ar: 'عسل', emoji: '🍯' },
    { name: 'Date Syrup', name_ar: 'دبس التمر', emoji: '🍯' },

    // 🧂 Basic Essentials
    { name: 'Salt', name_ar: 'ملح', emoji: '🧂' },
    { name: 'Baking Powder', name_ar: 'بيكنج باودر', emoji: '🧂' },
    { name: 'Baking Soda', name_ar: 'بيكنج صودا', emoji: '🧂' },
    { name: 'Yeast', name_ar: 'خميرة', emoji: '🍞' },

    // 🥫 Canned & Pantry Basics
    { name: 'Canned Beans', name_ar: 'فاصوليا معلبة', emoji: '🥫' },
    { name: 'Canned Corn', name_ar: 'ذرة معلبة', emoji: '🥫' },
    { name: 'Canned Tuna', name_ar: 'تونة معلبة', emoji: '🥫' },
    { name: 'Tomato Paste', name_ar: 'معجون طماطم', emoji: '🍅' },
    { name: 'Tomato Sauce', name_ar: 'صلصة طماطم', emoji: '🍅' }

  ]
},

{
  id: 'cat-meat-seafood',
  label: 'Meat, Poultry & Seafood',
  label_ar: 'لحوم ودواجن ومأكولات بحرية',
  icon: 'drumstick',
  order: 4,
  items: [

    // 🐔 Chicken
    { name: 'Whole Chicken', name_ar: 'دجاج كامل', emoji: '🍗' },
    { name: 'Chicken Breast', name_ar: 'صدر دجاج', emoji: '🍗' },
    { name: 'Chicken Thigh', name_ar: 'فخذ دجاج', emoji: '🍗' },
    { name: 'Chicken Drumsticks', name_ar: 'أفخاذ دجاج', emoji: '🍗' },
    { name: 'Chicken Wings', name_ar: 'أجنحة دجاج', emoji: '🍗' },
    { name: 'Chicken Mince', name_ar: 'دجاج مفروم', emoji: '🍗' },
    { name: 'Chicken Cubes', name_ar: 'مكعبات دجاج', emoji: '🍗' },
    { name: 'Chicken Liver', name_ar: 'كبدة دجاج', emoji: '🍗' },
    { name: 'Chicken Gizzard', name_ar: 'قوانص دجاج', emoji: '🍗' },
    { name: 'Chicken Sausage', name_ar: 'نقانق دجاج', emoji: '🌭' },
    { name: 'Chicken Burger Patty', name_ar: 'برغر دجاج', emoji: '🍔' },
    { name: 'Chicken Shawarma', name_ar: 'شاورما دجاج', emoji: '🥙' },

    // 🥩 Beef
    { name: 'Beef Steak', name_ar: 'ستيك لحم بقري', emoji: '🥩' },
    { name: 'Ribeye Steak', name_ar: 'ستيك ريب آي', emoji: '🥩' },
    { name: 'Sirloin Steak', name_ar: 'ستيك سيرلوين', emoji: '🥩' },
    { name: 'Beef Mince', name_ar: 'لحم بقري مفروم', emoji: '🥩' },
    { name: 'Beef Cubes', name_ar: 'مكعبات لحم بقري', emoji: '🥩' },
    { name: 'Beef Strips', name_ar: 'شرائح لحم بقري', emoji: '🥩' },
    { name: 'Beef Ribs', name_ar: 'ضلوع لحم بقري', emoji: '🥩' },
    { name: 'Beef Brisket', name_ar: 'صدر لحم بقري', emoji: '🥩' },
    { name: 'Beef Burger Patty', name_ar: 'برغر لحم بقري', emoji: '🍔' },
    { name: 'Beef Sausage', name_ar: 'نقانق لحم بقري', emoji: '🌭' },
    { name: 'Beef Shawarma', name_ar: 'شاورما لحم', emoji: '🥙' },
    { name: 'Corned Beef', name_ar: 'لحم معلب', emoji: '🥩' },

    // 🐑 Lamb & Goat
    { name: 'Lamb Chops', name_ar: 'ريش غنم', emoji: '🍖' },
    { name: 'Lamb Leg', name_ar: 'فخذ غنم', emoji: '🍖' },
    { name: 'Lamb Shoulder', name_ar: 'كتف غنم', emoji: '🍖' },
    { name: 'Lamb Mince', name_ar: 'لحم غنم مفروم', emoji: '🍖' },
    { name: 'Lamb Cubes', name_ar: 'مكعبات لحم غنم', emoji: '🍖' },
    { name: 'Goat Meat', name_ar: 'لحم ماعز', emoji: '🥩' },
    { name: 'Goat Curry Cuts', name_ar: 'قطع لحم ماعز', emoji: '🥩' },
    { name: 'Mutton Chops', name_ar: 'ريش ضأن', emoji: '🍖' },

    // 🥓 Processed Meats
    { name: 'Turkey Slices', name_ar: 'شرائح ديك رومي', emoji: '🥓' },
    { name: 'Beef Salami', name_ar: 'سلامي لحم بقري', emoji: '🥓' },
    { name: 'Chicken Mortadella', name_ar: 'مرتديلا دجاج', emoji: '🥓' },
    { name: 'Beef Mortadella', name_ar: 'مرتديلا لحم بقري', emoji: '🥓' },
    { name: 'Pepperoni', name_ar: 'بيبروني', emoji: '🥓' },
    { name: 'Hot Dogs', name_ar: 'هوت دوج', emoji: '🌭' },

    // 🐟 Fish (UAE Popular)
    { name: 'Hammour Fish', name_ar: 'هامور', emoji: '🐟' },
    { name: 'Kingfish', name_ar: 'كنعد', emoji: '🐟' },
    { name: 'Salmon', name_ar: 'سلمون', emoji: '🐟' },
    { name: 'Tuna', name_ar: 'تونة', emoji: '🐟' },
    { name: 'Tilapia', name_ar: 'بلطي', emoji: '🐟' },
    { name: 'Sardines', name_ar: 'سردين', emoji: '🐟' },
    { name: 'Mackerel', name_ar: 'ماكريل', emoji: '🐟' },
    { name: 'Sea Bass', name_ar: 'قاروص', emoji: '🐟' },
    { name: 'Sea Bream', name_ar: 'دنيس', emoji: '🐟' },

    // 🐟 Fish Cuts
    { name: 'Fish Fillet', name_ar: 'فيليه سمك', emoji: '🐟' },
    { name: 'Fish Steak Cut', name_ar: 'شرائح سمك', emoji: '🐟' },
    { name: 'Whole Cleaned Fish', name_ar: 'سمك منظف كامل', emoji: '🐟' },

    // 🦐 Seafood
    { name: 'Shrimp', name_ar: 'روبيان', emoji: '🦐' },
    { name: 'Jumbo Shrimp', name_ar: 'روبيان كبير', emoji: '🦐' },
    { name: 'Prawns', name_ar: 'جمبري', emoji: '🦐' },
    { name: 'Crab', name_ar: 'سلطعون', emoji: '🦀' },
    { name: 'Blue Crab', name_ar: 'سلطعون أزرق', emoji: '🦀' },
    { name: 'Lobster', name_ar: 'جراد البحر', emoji: '🦞' },
    { name: 'Squid', name_ar: 'حبار', emoji: '🦑' },
    { name: 'Calamari Rings', name_ar: 'حلقات كاليماري', emoji: '🦑' },
    { name: 'Octopus', name_ar: 'أخطبوط', emoji: '🐙' },
    { name: 'Mussels', name_ar: 'بلح البحر', emoji: '🦪' },
    { name: 'Oysters', name_ar: 'محار', emoji: '🦪' },

    // 🍱 Ready / Frozen (common in UAE apps)
    { name: 'Frozen Chicken Nuggets', name_ar: 'ناجتس دجاج مجمد', emoji: '🍗' },
    { name: 'Frozen Chicken Strips', name_ar: 'ستربس دجاج مجمد', emoji: '🍗' },
    { name: 'Frozen Fish Fingers', name_ar: 'أصابع سمك مجمدة', emoji: '🐟' },
    { name: 'Frozen Shrimp', name_ar: 'روبيان مجمد', emoji: '🦐' },
    { name: 'Frozen Burger Patty', name_ar: 'برغر مجمد', emoji: '🍔' }

  ]
},

{
  id: 'cat-dairy',
  label: 'Dairy & Eggs',
  label_ar: 'ألبان وبيض',
  icon: 'milk',
  order: 4,
  items: [

    // 🥛 Milk
    { name: 'Fresh Milk', name_ar: 'حليب طازج', emoji: '🥛' },
    { name: 'Full Cream Milk', name_ar: 'حليب كامل الدسم', emoji: '🥛' },
    { name: 'Low Fat Milk', name_ar: 'حليب قليل الدسم', emoji: '🥛' },
    { name: 'Skimmed Milk', name_ar: 'حليب خالي الدسم', emoji: '🥛' },
    { name: 'Lactose Free Milk', name_ar: 'حليب خالي من اللاكتوز', emoji: '🥛' },
    { name: 'Long Life Milk', name_ar: 'حليب طويل الأمد', emoji: '🥛' },
    { name: 'Camel Milk', name_ar: 'حليب الإبل', emoji: '🥛' },

    // 🥤 Flavored Milk
    { name: 'Chocolate Milk', name_ar: 'حليب بالشوكولاتة', emoji: '🥛' },
    { name: 'Strawberry Milk', name_ar: 'حليب بالفراولة', emoji: '🥛' },
    { name: 'Banana Milk', name_ar: 'حليب بالموز', emoji: '🥛' },

    // 🥣 Yogurt & Laban
    { name: 'Plain Yogurt', name_ar: 'زبادي', emoji: '🥣' },
    { name: 'Greek Yogurt', name_ar: 'زبادي يوناني', emoji: '🥣' },
    { name: 'Low Fat Yogurt', name_ar: 'زبادي قليل الدسم', emoji: '🥣' },
    { name: 'Flavored Yogurt', name_ar: 'زبادي بنكهات', emoji: '🥣' },
    { name: 'Strawberry Yogurt', name_ar: 'زبادي بالفراولة', emoji: '🥣' },
    { name: 'Mango Yogurt', name_ar: 'زبادي بالمانجو', emoji: '🥣' },
    { name: 'Probiotic Yogurt', name_ar: 'زبادي بروبيوتيك', emoji: '🥣' },

    { name: 'Laban Drink', name_ar: 'لبن', emoji: '🥛' },
    { name: 'Salted Laban', name_ar: 'لبن مالح', emoji: '🥛' },
    { name: 'Flavored Laban', name_ar: 'لبن منكه', emoji: '🥛' },

    // 🧀 Labneh & Cream
    { name: 'Labneh', name_ar: 'لبنة', emoji: '🥛' },
    { name: 'Labneh Balls', name_ar: 'لبنة مكورة', emoji: '🥛' },
    { name: 'Cream', name_ar: 'قشطة', emoji: '🥛' },
    { name: 'Whipping Cream', name_ar: 'كريمة خفق', emoji: '🥛' },
    { name: 'Cooking Cream', name_ar: 'كريمة طبخ', emoji: '🥛' },

    // 🧀 Cheese
    { name: 'Cheddar Cheese', name_ar: 'جبنة شيدر', emoji: '🧀' },
    { name: 'Mozzarella Cheese', name_ar: 'جبنة موزاريلا', emoji: '🧀' },
    { name: 'Feta Cheese', name_ar: 'جبنة فيتا', emoji: '🧀' },
    { name: 'Halloumi Cheese', name_ar: 'جبنة حلومي', emoji: '🧀' },
    { name: 'Cream Cheese', name_ar: 'جبنة كريمية', emoji: '🧀' },
    { name: 'Processed Cheese', name_ar: 'جبنة مطبوخة', emoji: '🧀' },
    { name: 'Sliced Cheese', name_ar: 'جبنة شرائح', emoji: '🧀' },
    { name: 'Spreadable Cheese', name_ar: 'جبنة قابلة للدهن', emoji: '🧀' },
    { name: 'Parmesan Cheese', name_ar: 'جبنة بارميزان', emoji: '🧀' },
    { name: 'Gouda Cheese', name_ar: 'جبنة جودة', emoji: '🧀' },
    { name: 'Swiss Cheese', name_ar: 'جبنة سويسرية', emoji: '🧀' },
    { name: 'Blue Cheese', name_ar: 'جبنة زرقاء', emoji: '🧀' },

    // 🧈 Butter & Alternatives
    { name: 'Butter', name_ar: 'زبدة', emoji: '🧈' },
    { name: 'Salted Butter', name_ar: 'زبدة مملحة', emoji: '🧈' },
    { name: 'Unsalted Butter', name_ar: 'زبدة غير مملحة', emoji: '🧈' },
    { name: 'Ghee', name_ar: 'سمن', emoji: '🧈' },
    { name: 'Margarine', name_ar: 'مارجرين', emoji: '🧈' },

    // 🥚 Eggs
    { name: 'White Eggs', name_ar: 'بيض أبيض', emoji: '🥚' },
    { name: 'Brown Eggs', name_ar: 'بيض بني', emoji: '🥚' },
    { name: 'Free Range Eggs', name_ar: 'بيض حر', emoji: '🥚' },
    { name: 'Organic Eggs', name_ar: 'بيض عضوي', emoji: '🥚' },
    { name: 'Quail Eggs', name_ar: 'بيض السمان', emoji: '🥚' },

    // 🥫 Milk Products
    { name: 'Condensed Milk', name_ar: 'حليب مكثف', emoji: '🥛' },
    { name: 'Evaporated Milk', name_ar: 'حليب مبخر', emoji: '🥛' },
    { name: 'Milk Powder', name_ar: 'حليب مجفف', emoji: '🥛' },

    // 🍦 Desserts (Dairy-based)
    { name: 'Ice Cream', name_ar: 'آيس كريم', emoji: '🍨' },
    { name: 'Gelato', name_ar: 'جيلاتو', emoji: '🍨' },
    { name: 'Frozen Yogurt', name_ar: 'زبادي مجمد', emoji: '🍨' }

  ]
},

{
  id: 'cat-beverages',
  label: 'Beverages',
  label_ar: 'مشروبات',
  icon: 'cup',
  order: 5,
  items: [

    // 💧 Water
    { name: 'Mineral Water', name_ar: 'مياه معدنية', emoji: '💧' },
    { name: 'Drinking Water', name_ar: 'مياه شرب', emoji: '💧' },
    { name: 'Sparkling Water', name_ar: 'مياه غازية', emoji: '💧' },
    { name: 'Alkaline Water', name_ar: 'مياه قلوية', emoji: '💧' },
    { name: 'Flavored Water', name_ar: 'مياه منكهة', emoji: '💧' },

    // 🧃 Juices
    { name: 'Orange Juice', name_ar: 'عصير برتقال', emoji: '🧃' },
    { name: 'Apple Juice', name_ar: 'عصير تفاح', emoji: '🧃' },
    { name: 'Mango Juice', name_ar: 'عصير مانجو', emoji: '🧃' },
    { name: 'Pineapple Juice', name_ar: 'عصير أناناس', emoji: '🧃' },
    { name: 'Guava Juice', name_ar: 'عصير جوافة', emoji: '🧃' },
    { name: 'Mixed Fruit Juice', name_ar: 'عصير فواكه مشكل', emoji: '🧃' },
    { name: 'Fresh Juice', name_ar: 'عصير طازج', emoji: '🧃' },
    { name: 'Lemon Juice', name_ar: 'عصير ليمون', emoji: '🧃' },
    { name: 'Watermelon Juice', name_ar: 'عصير بطيخ', emoji: '🧃' },

    // 🥤 Soft Drinks
    { name: 'Cola', name_ar: 'كولا', emoji: '🥤' },
    { name: 'Diet Cola', name_ar: 'كولا دايت', emoji: '🥤' },
    { name: 'Zero Cola', name_ar: 'كولا زيرو', emoji: '🥤' },
    { name: 'Lemon Soda', name_ar: 'صودا ليمون', emoji: '🥤' },
    { name: 'Orange Soda', name_ar: 'صودا برتقال', emoji: '🥤' },
    { name: 'Soft Drinks Can', name_ar: 'مشروبات غازية علب', emoji: '🥤' },

    // ⚡ Energy & Sports
    { name: 'Energy Drink', name_ar: 'مشروب طاقة', emoji: '⚡' },
    { name: 'Sugar Free Energy Drink', name_ar: 'مشروب طاقة بدون سكر', emoji: '⚡' },
    { name: 'Sports Drink', name_ar: 'مشروب رياضي', emoji: '🥤' },
    { name: 'Electrolyte Drink', name_ar: 'مشروب إلكترولايت', emoji: '🥤' },

    // ☕ Coffee
    { name: 'Arabic Coffee', name_ar: 'قهوة عربية', emoji: '☕' },
    { name: 'Ground Coffee', name_ar: 'قهوة مطحونة', emoji: '☕' },
    { name: 'Coffee Beans', name_ar: 'حبوب قهوة', emoji: '☕' },
    { name: 'Instant Coffee', name_ar: 'قهوة فورية', emoji: '☕' },
    { name: 'Espresso Coffee', name_ar: 'قهوة اسبريسو', emoji: '☕' },
    { name: 'Cappuccino Mix', name_ar: 'كابتشينو', emoji: '☕' },
    { name: 'Latte Mix', name_ar: 'لاتيه', emoji: '☕' },

    // 🍵 Tea
    { name: 'Black Tea', name_ar: 'شاي أسود', emoji: '🍵' },
    { name: 'Green Tea', name_ar: 'شاي أخضر', emoji: '🍵' },
    { name: 'Karak Tea', name_ar: 'شاي كرك', emoji: '🍵' },
    { name: 'Herbal Tea', name_ar: 'شاي أعشاب', emoji: '🍵' },
    { name: 'Chamomile Tea', name_ar: 'شاي بابونج', emoji: '🍵' },
    { name: 'Mint Tea', name_ar: 'شاي نعناع', emoji: '🍵' },

    // 🥛 Dairy Beverages
    { name: 'Laban Drink', name_ar: 'لبن', emoji: '🥛' },
    { name: 'Flavored Milk Drink', name_ar: 'حليب منكه', emoji: '🥛' },
    { name: 'Protein Shake', name_ar: 'مشروب بروتين', emoji: '🥛' },

    // 🌴 Traditional Middle Eastern Drinks
    { name: 'Tamarind Drink', name_ar: 'تمر هندي', emoji: '🧃' },
    { name: 'Jallab', name_ar: 'جلاب', emoji: '🧃' },
    { name: 'Rose Water Drink', name_ar: 'شراب ماء الورد', emoji: '🧃' },
    { name: 'Qamar El Din', name_ar: 'قمر الدين', emoji: '🧃' },

    // 🧊 Ready-to-Drink
    { name: 'Iced Coffee', name_ar: 'قهوة مثلجة', emoji: '🧊' },
    { name: 'Iced Tea', name_ar: 'شاي مثلج', emoji: '🧊' },
    { name: 'Cold Brew Coffee', name_ar: 'قهوة باردة', emoji: '🧊' }

  ]
},

{
  id: 'cat-frozen-chilled',
  label: 'Frozen & Chilled Foods',
  label_ar: 'أطعمة مجمدة ومبردة',
  icon: 'snowflake',
  order: 6,
  items: [

    // 🥦 Frozen Vegetables
    { name: 'Frozen Peas', name_ar: 'بازلاء مجمدة', emoji: '🫛' },
    { name: 'Frozen Corn', name_ar: 'ذرة مجمدة', emoji: '🌽' },
    { name: 'Frozen Mixed Vegetables', name_ar: 'خضروات مشكلة مجمدة', emoji: '🥦' },
    { name: 'Frozen Spinach', name_ar: 'سبانخ مجمدة', emoji: '🥬' },
    { name: 'Frozen Broccoli', name_ar: 'بروكلي مجمد', emoji: '🥦' },
    { name: 'Frozen Cauliflower', name_ar: 'قرنبيط مجمد', emoji: '🥦' },
    { name: 'Frozen Okra', name_ar: 'بامية مجمدة', emoji: '🌿' },

    // 🍓 Frozen Fruits
    { name: 'Frozen Strawberry', name_ar: 'فراولة مجمدة', emoji: '🍓' },
    { name: 'Frozen Mango', name_ar: 'مانجو مجمد', emoji: '🥭' },
    { name: 'Frozen Berries Mix', name_ar: 'توت مشكل مجمد', emoji: '🫐' },
    { name: 'Frozen Pineapple', name_ar: 'أناناس مجمد', emoji: '🍍' },

    // 🍗 Frozen Meat & Poultry
    { name: 'Frozen Whole Chicken', name_ar: 'دجاج كامل مجمد', emoji: '🍗' },
    { name: 'Frozen Chicken Breast', name_ar: 'صدر دجاج مجمد', emoji: '🍗' },
    { name: 'Frozen Chicken Nuggets', name_ar: 'ناجتس دجاج مجمد', emoji: '🍗' },
    { name: 'Frozen Chicken Strips', name_ar: 'ستربس دجاج مجمد', emoji: '🍗' },
    { name: 'Frozen Chicken Wings', name_ar: 'أجنحة دجاج مجمدة', emoji: '🍗' },
    { name: 'Frozen Beef Burger', name_ar: 'برغر لحم مجمد', emoji: '🍔' },
    { name: 'Frozen Minced Meat', name_ar: 'لحم مفروم مجمد', emoji: '🥩' },

    // 🐟 Frozen Seafood
    { name: 'Frozen Fish Fillet', name_ar: 'فيليه سمك مجمد', emoji: '🐟' },
    { name: 'Frozen Shrimp', name_ar: 'روبيان مجمد', emoji: '🦐' },
    { name: 'Frozen Prawns', name_ar: 'جمبري مجمد', emoji: '🦐' },
    { name: 'Frozen Calamari', name_ar: 'كاليماري مجمد', emoji: '🦑' },
    { name: 'Frozen Fish Fingers', name_ar: 'أصابع سمك مجمدة', emoji: '🐟' },

    // 🍕 Ready Meals (Very common in UAE apps)
    { name: 'Frozen Pizza', name_ar: 'بيتزا مجمدة', emoji: '🍕' },
    { name: 'Frozen Lasagna', name_ar: 'لازانيا مجمدة', emoji: '🍝' },
    { name: 'Frozen Pasta Meal', name_ar: 'وجبة مكرونة مجمدة', emoji: '🍝' },
    { name: 'Frozen Burger Meal', name_ar: 'وجبة برغر مجمدة', emoji: '🍔' },
    { name: 'Frozen Shawarma', name_ar: 'شاورما مجمدة', emoji: '🥙' },

    // 🥟 Snacks & Appetizers
    { name: 'Frozen Samosa', name_ar: 'سمبوسة مجمدة', emoji: '🥟' },
    { name: 'Frozen Spring Rolls', name_ar: 'سبرنغ رول مجمد', emoji: '🥟' },
    { name: 'Frozen Paratha', name_ar: 'براتا مجمدة', emoji: '🫓' },
    { name: 'Frozen Falafel', name_ar: 'فلافل مجمدة', emoji: '🧆' },
    { name: 'Frozen Fries', name_ar: 'بطاطس مقلية مجمدة', emoji: '🍟' },

    // 🍨 Ice Cream & Desserts
    { name: 'Ice Cream', name_ar: 'آيس كريم', emoji: '🍨' },
    { name: 'Gelato', name_ar: 'جيلاتو', emoji: '🍨' },
    { name: 'Sorbet', name_ar: 'سوربيه', emoji: '🍨' },
    { name: 'Frozen Yogurt', name_ar: 'زبادي مجمد', emoji: '🍨' },
    { name: 'Ice Cream Bars', name_ar: 'آيس كريم على عصا', emoji: '🍦' },
    { name: 'Ice Cream Tub', name_ar: 'علبة آيس كريم', emoji: '🍨' },

    // 🧊 Chilled Ready Foods
    { name: 'Ready Salad', name_ar: 'سلطة جاهزة', emoji: '🥗' },
    { name: 'Cut Fruits', name_ar: 'فواكه مقطعة', emoji: '🍓' },
    { name: 'Sandwich', name_ar: 'ساندويتش', emoji: '🥪' },
    { name: 'Wraps', name_ar: 'راب', emoji: '🌯' },
    { name: 'Hummus', name_ar: 'حمص', emoji: '🫙' },
    { name: 'Mutabbal', name_ar: 'متبل', emoji: '🍆' },
    { name: 'Tabbouleh', name_ar: 'تبولة', emoji: '🥗' },

    // 🧃 Chilled Drinks
    { name: 'Chilled Juice', name_ar: 'عصير مبرد', emoji: '🧃' },
    { name: 'Chilled Smoothie', name_ar: 'سموثي مبرد', emoji: '🥤' },
    { name: 'Cold Coffee Drink', name_ar: 'قهوة باردة جاهزة', emoji: '☕' }

  ]
},

{
  id: 'cat-bakery',
  label: 'Bakery',
  label_ar: 'مخبوزات',
  icon: 'bread',
  order: 7,
  items: [

    // 🫓 Arabic Bread (UAE essentials)
    { name: 'Arabic Bread', name_ar: 'خبز عربي', emoji: '🫓' },
    { name: 'Pita Bread', name_ar: 'خبز بيتا', emoji: '🫓' },
    { name: 'Lebanese Bread', name_ar: 'خبز لبناني', emoji: '🫓' },
    { name: 'Khubz', name_ar: 'خبز', emoji: '🫓' },
    { name: 'Saj Bread', name_ar: 'خبز صاج', emoji: '🫓' },
    { name: 'Tannour Bread', name_ar: 'خبز تنور', emoji: '🫓' },

    // 🍞 Sandwich & Daily Bread
    { name: 'White Bread', name_ar: 'خبز أبيض', emoji: '🍞' },
    { name: 'Brown Bread', name_ar: 'خبز أسمر', emoji: '🍞' },
    { name: 'Whole Wheat Bread', name_ar: 'خبز قمح كامل', emoji: '🍞' },
    { name: 'Multigrain Bread', name_ar: 'خبز متعدد الحبوب', emoji: '🍞' },
    { name: 'Toast Bread', name_ar: 'خبز توست', emoji: '🍞' },
    { name: 'Sandwich Bread', name_ar: 'خبز ساندويتش', emoji: '🍞' },

    // 🍔 Buns
    { name: 'Burger Buns', name_ar: 'خبز برغر', emoji: '🍔' },
    { name: 'Hotdog Buns', name_ar: 'خبز هوت دوج', emoji: '🌭' },
    { name: 'Mini Buns', name_ar: 'خبز صغير', emoji: '🍞' },

    // 🥐 Pastries
    { name: 'Croissant', name_ar: 'كرواسون', emoji: '🥐' },
    { name: 'Chocolate Croissant', name_ar: 'كرواسون شوكولاتة', emoji: '🥐' },
    { name: 'Cheese Croissant', name_ar: 'كرواسون جبن', emoji: '🥐' },
    { name: 'Danish Pastry', name_ar: 'دانش', emoji: '🥐' },
    { name: 'Puff Pastry', name_ar: 'عجينة بف باستري', emoji: '🥐' },

    // 🧁 Cakes & Desserts
    { name: 'Cake', name_ar: 'كيك', emoji: '🍰' },
    { name: 'Chocolate Cake', name_ar: 'كيك شوكولاتة', emoji: '🍰' },
    { name: 'Vanilla Cake', name_ar: 'كيك فانيليا', emoji: '🍰' },
    { name: 'Cheesecake', name_ar: 'تشيز كيك', emoji: '🍰' },
    { name: 'Cupcake', name_ar: 'كب كيك', emoji: '🧁' },
    { name: 'Muffin', name_ar: 'مافن', emoji: '🧁' },
    { name: 'Brownies', name_ar: 'براونيز', emoji: '🍫' },

    // 🍩 Sweet Bakery
    { name: 'Donut', name_ar: 'دونات', emoji: '🍩' },
    { name: 'Glazed Donut', name_ar: 'دونات مزججة', emoji: '🍩' },
    { name: 'Chocolate Donut', name_ar: 'دونات شوكولاتة', emoji: '🍩' },

    // 🥖 European Bread
    { name: 'Baguette', name_ar: 'باغيت', emoji: '🥖' },
    { name: 'Sourdough Bread', name_ar: 'خبز ساوردو', emoji: '🍞' },
    { name: 'Ciabatta', name_ar: 'تشاباتا', emoji: '🍞' },
    { name: 'Focaccia', name_ar: 'فوكاتشيا', emoji: '🍞' },

    // 🫓 Middle Eastern Bakery
    { name: 'Manakish Zaatar', name_ar: 'مناقيش زعتر', emoji: '🫓' },
    { name: 'Manakish Cheese', name_ar: 'مناقيش جبن', emoji: '🫓' },
    { name: 'Fatayer Spinach', name_ar: 'فطائر سبانخ', emoji: '🥟' },
    { name: 'Fatayer Cheese', name_ar: 'فطائر جبن', emoji: '🥟' },
    { name: 'Fatayer Meat', name_ar: 'فطائر لحم', emoji: '🥟' },

    // 🥟 Savory Snacks
    { name: 'Samosa', name_ar: 'سمبوسة', emoji: '🥟' },
    { name: 'Spring Rolls', name_ar: 'سبرنغ رول', emoji: '🥟' },
    { name: 'Savory Pies', name_ar: 'فطائر مالحة', emoji: '🥧' },

    // 🍪 Cookies & Biscuits
    { name: 'Cookies', name_ar: 'كوكيز', emoji: '🍪' },
    { name: 'Chocolate Chip Cookies', name_ar: 'كوكيز بالشوكولاتة', emoji: '🍪' },
    { name: 'Oat Cookies', name_ar: 'كوكيز شوفان', emoji: '🍪' },
    { name: 'Biscuits', name_ar: 'بسكويت', emoji: '🍪' },

    // 🥯 Specialty Bread
    { name: 'Bagel', name_ar: 'بيغل', emoji: '🥯' },
    { name: 'Brioche', name_ar: 'بريوش', emoji: '🍞' },
    { name: 'Breadsticks', name_ar: 'أعواد خبز', emoji: '🥖' }

  ]
},

{
  id: 'cat-snacks',
  label: 'Snacks & Confectionery',
  label_ar: 'وجبات خفيفة وحلويات',
  icon: 'cookie',
  order: 8,
  items: [

    // 🥔 Chips & Salty Snacks
    { name: 'Potato Chips', name_ar: 'شيبس بطاطس', emoji: '🥔' },
    { name: 'Tortilla Chips', name_ar: 'رقائق تورتيلا', emoji: '🌮' },
    { name: 'Nachos', name_ar: 'ناتشوز', emoji: '🌮' },
    { name: 'Popcorn', name_ar: 'فشار', emoji: '🍿' },
    { name: 'Pretzels', name_ar: 'بريتزل', emoji: '🥨' },
    { name: 'Corn Snacks', name_ar: 'سناكات الذرة', emoji: '🌽' },

    // 🍪 Biscuits & Cookies
    { name: 'Biscuits', name_ar: 'بسكويت', emoji: '🍪' },
    { name: 'Digestive Biscuits', name_ar: 'بسكويت دايجستيف', emoji: '🍪' },
    { name: 'Cream Biscuits', name_ar: 'بسكويت محشو', emoji: '🍪' },
    { name: 'Cookies', name_ar: 'كوكيز', emoji: '🍪' },
    { name: 'Chocolate Chip Cookies', name_ar: 'كوكيز بالشوكولاتة', emoji: '🍪' },
    { name: 'Oat Cookies', name_ar: 'كوكيز شوفان', emoji: '🍪' },

    // 🍫 Chocolate
    { name: 'Chocolate Bar', name_ar: 'لوح شوكولاتة', emoji: '🍫' },
    { name: 'Milk Chocolate', name_ar: 'شوكولاتة بالحليب', emoji: '🍫' },
    { name: 'Dark Chocolate', name_ar: 'شوكولاتة داكنة', emoji: '🍫' },
    { name: 'White Chocolate', name_ar: 'شوكولاتة بيضاء', emoji: '🍫' },
    { name: 'Chocolate Spread', name_ar: 'شوكولاتة قابلة للدهن', emoji: '🍫' },
    { name: 'Hazelnut Spread', name_ar: 'كريمة بندق', emoji: '🍫' },

    // 🍬 Candy & Sweets
    { name: 'Candy', name_ar: 'حلوى', emoji: '🍬' },
    { name: 'Lollipop', name_ar: 'مصاصة', emoji: '🍭' },
    { name: 'Gummies', name_ar: 'حلوى مطاطية', emoji: '🍬' },
    { name: 'Jelly Candy', name_ar: 'جيلي', emoji: '🍬' },
    { name: 'Marshmallows', name_ar: 'مارشميلو', emoji: '🍡' },
    { name: 'Chewing Gum', name_ar: 'علكة', emoji: '🍬' },

    // 🌴 Middle Eastern Sweets (UAE essential)
    { name: 'Dates Sweets', name_ar: 'حلويات التمر', emoji: '🌴' },
    { name: 'Baklava', name_ar: 'بقلاوة', emoji: '🍯' },
    { name: 'Kunafa', name_ar: 'كنافة', emoji: '🍰' },
    { name: 'Basbousa', name_ar: 'بسبوسة', emoji: '🍰' },
    { name: 'Maamoul', name_ar: 'معمول', emoji: '🍪' },
    { name: 'Halva', name_ar: 'حلاوة', emoji: '🍯' },
    { name: 'Turkish Delight', name_ar: 'راحة الحلقوم', emoji: '🍬' },

    // 🥜 Nuts & Seeds
    { name: 'Mixed Nuts', name_ar: 'مكسرات مشكلة', emoji: '🥜' },
    { name: 'Almonds', name_ar: 'لوز', emoji: '🥜' },
    { name: 'Cashews', name_ar: 'كاجو', emoji: '🥜' },
    { name: 'Pistachios', name_ar: 'فستق', emoji: '🥜' },
    { name: 'Peanuts', name_ar: 'فول سوداني', emoji: '🥜' },
    { name: 'Sunflower Seeds', name_ar: 'بذور عباد الشمس', emoji: '🌻' },

    // 🍫 Snack Bars
    { name: 'Energy Bars', name_ar: 'ألواح طاقة', emoji: '🍫' },
    { name: 'Protein Bars', name_ar: 'ألواح بروتين', emoji: '🍫' },
    { name: 'Granola Bars', name_ar: 'ألواح جرانولا', emoji: '🍫' },

    // 🍿 Ready Snack Packs
    { name: 'Snack Mix', name_ar: 'خليط سناكات', emoji: '🍿' },
    { name: 'Trail Mix', name_ar: 'مكسرات مع فواكه مجففة', emoji: '🥜' },
    { name: 'Rice Cakes', name_ar: 'كعك الأرز', emoji: '🍘' }

  ]
},

{
  id: 'cat-household',
  label: 'Household Essentials',
  label_ar: 'مستلزمات منزلية',
  icon: 'home',
  order: 9,
  items: [

    // 🧼 Cleaning Products
    { name: 'All Purpose Cleaner', name_ar: 'منظف متعدد الاستخدامات', emoji: '🧴' },
    { name: 'Disinfectant Spray', name_ar: 'بخاخ معقم', emoji: '🧴' },
    { name: 'Surface Cleaner', name_ar: 'منظف الأسطح', emoji: '🧴' },
    { name: 'Bathroom Cleaner', name_ar: 'منظف الحمام', emoji: '🚽' },
    { name: 'Toilet Cleaner', name_ar: 'منظف المرحاض', emoji: '🚽' },
    { name: 'Glass Cleaner', name_ar: 'منظف الزجاج', emoji: '🪟' },
    { name: 'Floor Cleaner', name_ar: 'منظف الأرضيات', emoji: '🧹' },
    { name: 'Kitchen Cleaner', name_ar: 'منظف المطبخ', emoji: '🧴' },
    { name: 'Bleach', name_ar: 'مبيض', emoji: '🧴' },

    // 🍽 Dishwashing
    { name: 'Dishwashing Liquid', name_ar: 'سائل غسيل الصحون', emoji: '🧽' },
    { name: 'Dishwasher Tablets', name_ar: 'أقراص غسالة الصحون', emoji: '🧼' },
    { name: 'Dishwasher Powder', name_ar: 'مسحوق غسالة الصحون', emoji: '🧼' },
    { name: 'Dish Sponges', name_ar: 'إسفنج غسيل الصحون', emoji: '🧽' },
    { name: 'Scrub Pads', name_ar: 'ليف تنظيف', emoji: '🧽' },

    // 🧺 Laundry
    { name: 'Laundry Detergent Powder', name_ar: 'مسحوق غسيل', emoji: '🧺' },
    { name: 'Laundry Liquid', name_ar: 'سائل غسيل', emoji: '🧺' },
    { name: 'Fabric Softener', name_ar: 'منعم أقمشة', emoji: '🧴' },
    { name: 'Stain Remover', name_ar: 'مزيل بقع', emoji: '🧴' },
    { name: 'Laundry Capsules', name_ar: 'كبسولات غسيل', emoji: '🧺' },

    // 🧻 Paper Products
    { name: 'Toilet Paper', name_ar: 'ورق حمام', emoji: '🧻' },
    { name: 'Kitchen Towels', name_ar: 'مناديل مطبخ', emoji: '🧻' },
    { name: 'Facial Tissues', name_ar: 'مناديل وجه', emoji: '🤧' },
    { name: 'Wet Wipes', name_ar: 'مناديل مبللة', emoji: '🧻' },

    // 🗑 Waste Management
    { name: 'Garbage Bags', name_ar: 'أكياس قمامة', emoji: '🗑️' },
    { name: 'Trash Bags Large', name_ar: 'أكياس قمامة كبيرة', emoji: '🗑️' },
    { name: 'Trash Bags Small', name_ar: 'أكياس قمامة صغيرة', emoji: '🗑️' },

    // 🍳 Kitchen Essentials
    { name: 'Aluminum Foil', name_ar: 'ورق ألمنيوم', emoji: '🍽' },
    { name: 'Cling Wrap', name_ar: 'نايلون تغليف', emoji: '🍽' },
    { name: 'Baking Paper', name_ar: 'ورق خبز', emoji: '🍽' },
    { name: 'Food Storage Bags', name_ar: 'أكياس حفظ الطعام', emoji: '🛍️' },
    { name: 'Plastic Containers', name_ar: 'علب بلاستيكية', emoji: '🥡' },

    // 🌬 Air Care
    { name: 'Air Freshener Spray', name_ar: 'معطر جو', emoji: '🌸' },
    { name: 'Air Freshener Gel', name_ar: 'معطر جل', emoji: '🌸' },
    { name: 'Scented Candles', name_ar: 'شموع معطرة', emoji: '🕯️' },

    // 🦠 Hygiene & Disinfection
    { name: 'Hand Sanitizer', name_ar: 'معقم يدين', emoji: '🧴' },
    { name: 'Disinfectant Wipes', name_ar: 'مناديل معقمة', emoji: '🧻' },
    { name: 'Antibacterial Spray', name_ar: 'بخاخ مضاد للبكتيريا', emoji: '🧴' },

    // 🧹 Cleaning Tools
    { name: 'Broom', name_ar: 'مكنسة يدوية', emoji: '🧹' },
    { name: 'Mop', name_ar: 'ممسحة', emoji: '🧹' },
    { name: 'Bucket', name_ar: 'دلو', emoji: '🪣' },
    { name: 'Cleaning Gloves', name_ar: 'قفازات تنظيف', emoji: '🧤' },
    { name: 'Dustpan', name_ar: 'مجرفة', emoji: '🧹' }

  ]
},

{
  id: 'cat-personal-care',
  label: 'Personal Care',
  label_ar: 'العناية الشخصية',
  icon: 'user',
  order: 10,
  items: [

    // 🧴 Hair Care
    { name: 'Shampoo', name_ar: 'شامبو', emoji: '🧴' },
    { name: 'Conditioner', name_ar: 'بلسم', emoji: '🧴' },
    { name: 'Hair Oil', name_ar: 'زيت شعر', emoji: '🧴' },
    { name: 'Hair Cream', name_ar: 'كريم شعر', emoji: '🧴' },
    { name: 'Hair Gel', name_ar: 'جل شعر', emoji: '🧴' },
    { name: 'Hair Spray', name_ar: 'مثبت شعر', emoji: '🧴' },
    { name: 'Hair Mask', name_ar: 'ماسك شعر', emoji: '🧴' },

    // 🛁 Body Care
    { name: 'Body Wash', name_ar: 'غسول الجسم', emoji: '🛁' },
    { name: 'Bar Soap', name_ar: 'صابون', emoji: '🧼' },
    { name: 'Liquid Soap', name_ar: 'صابون سائل', emoji: '🧴' },
    { name: 'Body Lotion', name_ar: 'لوشن الجسم', emoji: '🧴' },
    { name: 'Body Cream', name_ar: 'كريم الجسم', emoji: '🧴' },
    { name: 'Body Scrub', name_ar: 'مقشر الجسم', emoji: '🧴' },

    // 🧴 Skin Care
    { name: 'Face Wash', name_ar: 'غسول الوجه', emoji: '🧴' },
    { name: 'Face Cream', name_ar: 'كريم الوجه', emoji: '🧴' },
    { name: 'Moisturizer', name_ar: 'مرطب', emoji: '🧴' },
    { name: 'Sunscreen', name_ar: 'واقي شمس', emoji: '🌞' },
    { name: 'Face Serum', name_ar: 'سيروم الوجه', emoji: '🧴' },
    { name: 'Face Mask', name_ar: 'ماسك الوجه', emoji: '🧴' },
    { name: 'Makeup Remover', name_ar: 'مزيل مكياج', emoji: '🧴' },

    // 🪥 Oral Care
    { name: 'Toothpaste', name_ar: 'معجون أسنان', emoji: '🪥' },
    { name: 'Toothbrush', name_ar: 'فرشاة أسنان', emoji: '🪥' },
    { name: 'Electric Toothbrush', name_ar: 'فرشاة أسنان كهربائية', emoji: '🪥' },
    { name: 'Mouthwash', name_ar: 'غسول فم', emoji: '🧴' },
    { name: 'Dental Floss', name_ar: 'خيط تنظيف الأسنان', emoji: '🧵' },

    // 🚿 Deodorants & Fragrance
    { name: 'Deodorant Spray', name_ar: 'مزيل عرق بخاخ', emoji: '🌸' },
    { name: 'Roll On Deodorant', name_ar: 'مزيل عرق رول', emoji: '🌸' },
    { name: 'Perfume', name_ar: 'عطر', emoji: '🌸' },
    { name: 'Body Mist', name_ar: 'معطر جسم', emoji: '🌸' },

    // 🪒 Grooming
    { name: 'Razor', name_ar: 'شفرة حلاقة', emoji: '🪒' },
    { name: 'Shaving Cream', name_ar: 'كريم حلاقة', emoji: '🧴' },
    { name: 'After Shave', name_ar: 'لوشن بعد الحلاقة', emoji: '🧴' },
    { name: 'Hair Removal Cream', name_ar: 'كريم إزالة الشعر', emoji: '🧴' },

    // 🧻 Hygiene Essentials
    { name: 'Wet Wipes', name_ar: 'مناديل مبللة', emoji: '🧻' },
    { name: 'Cotton Pads', name_ar: 'قطن تجميلي', emoji: '🧻' },
    { name: 'Cotton Buds', name_ar: 'أعواد قطن', emoji: '🧻' },
    { name: 'Hand Sanitizer', name_ar: 'معقم يدين', emoji: '🧴' },

    // 👶 Feminine & Care
    { name: 'Sanitary Pads', name_ar: 'فوط صحية', emoji: '🧻' },
    { name: 'Tampons', name_ar: 'تامبون', emoji: '🧻' },
    { name: 'Panty Liners', name_ar: 'فوط يومية', emoji: '🧻' }

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
