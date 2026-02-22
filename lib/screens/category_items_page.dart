import 'package:flutter/material.dart';
import '../widgets/add_item_details_sheet.dart';

/// Maps every grocery category to a list of common items with an emoji.
const Map<String, List<Map<String, dynamic>>> _categoryItems = {
  'Fruits': [
    {'name': 'Apple',        'emoji': '🍎'},
    {'name': 'Banana',       'emoji': '🍌'},
    {'name': 'Orange',       'emoji': '🍊'},
    {'name': 'Grapes',       'emoji': '🍇'},
    {'name': 'Strawberry',   'emoji': '🍓'},
    {'name': 'Watermelon',   'emoji': '🍉'},
    {'name': 'Mango',        'emoji': '🥭'},
    {'name': 'Pineapple',    'emoji': '🍍'},
    {'name': 'Peach',        'emoji': '🍑'},
    {'name': 'Pear',         'emoji': '🍐'},
    {'name': 'Cherry',       'emoji': '🍒'},
    {'name': 'Lemon',        'emoji': '🍋'},
    {'name': 'Coconut',      'emoji': '🥥'},
    {'name': 'Blueberry',    'emoji': '🫐'},
    {'name': 'Kiwi',         'emoji': '🥝'},
    {'name': 'Avocado',      'emoji': '🥑'},
    {'name': 'Melon',        'emoji': '🍈'},
    {'name': 'Pomegranate',  'emoji': '🍑'},
    {'name': 'Plum',         'emoji': '🍑'},
    {'name': 'Fig',          'emoji': '🫐'},
  ],
  'Vegetables': [
    {'name': 'Carrot',       'emoji': '🥕'},
    {'name': 'Broccoli',     'emoji': '🥦'},
    {'name': 'Spinach',      'emoji': '🥬'},
    {'name': 'Tomato',       'emoji': '🍅'},
    {'name': 'Cucumber',     'emoji': '🥒'},
    {'name': 'Lettuce',      'emoji': '🥬'},
    {'name': 'Onion',        'emoji': '🧅'},
    {'name': 'Garlic',       'emoji': '🧄'},
    {'name': 'Potato',       'emoji': '🥔'},
    {'name': 'Sweet Potato', 'emoji': '🍠'},
    {'name': 'Bell Pepper',  'emoji': '🫑'},
    {'name': 'Corn',         'emoji': '🌽'},
    {'name': 'Mushroom',     'emoji': '🍄'},
    {'name': 'Celery',       'emoji': '🥬'},
    {'name': 'Zucchini',     'emoji': '🥒'},
    {'name': 'Eggplant',     'emoji': '🍆'},
    {'name': 'Cauliflower',  'emoji': '🥦'},
    {'name': 'Beetroot',     'emoji': '🫐'},
    {'name': 'Asparagus',    'emoji': '🌿'},
    {'name': 'Peas',         'emoji': '🟢'},
  ],
  'Meat': [
    {'name': 'Chicken Breast',  'emoji': '🍗'},
    {'name': 'Chicken Thighs',  'emoji': '🍗'},
    {'name': 'Ground Beef',     'emoji': '🥩'},
    {'name': 'Beef Steak',      'emoji': '🥩'},
    {'name': 'Lamb Chops',      'emoji': '🥩'},
    {'name': 'Pork Chops',      'emoji': '🥩'},
    {'name': 'Bacon',           'emoji': '🥓'},
    {'name': 'Sausage',         'emoji': '🌭'},
    {'name': 'Turkey',          'emoji': '🦃'},
    {'name': 'Veal',            'emoji': '🥩'},
    {'name': 'Duck',            'emoji': '🦆'},
    {'name': 'Ribs',            'emoji': '🥩'},
    {'name': 'Minced Lamb',     'emoji': '🥩'},
    {'name': 'Hot Dogs',        'emoji': '🌭'},
    {'name': 'Deli Ham',        'emoji': '🥩'},
    {'name': 'Salami',          'emoji': '🥩'},
  ],
  'Seafood': [
    {'name': 'Salmon',     'emoji': '🐟'},
    {'name': 'Tuna',       'emoji': '🐟'},
    {'name': 'Shrimp',     'emoji': '🍤'},
    {'name': 'Crab',       'emoji': '🦀'},
    {'name': 'Lobster',    'emoji': '🦞'},
    {'name': 'Sardines',   'emoji': '🐟'},
    {'name': 'Cod',        'emoji': '🐟'},
    {'name': 'Tilapia',    'emoji': '🐠'},
    {'name': 'Oysters',    'emoji': '🦪'},
    {'name': 'Mussels',    'emoji': '🦪'},
    {'name': 'Clams',      'emoji': '🦪'},
    {'name': 'Squid',      'emoji': '🦑'},
    {'name': 'Octopus',    'emoji': '🐙'},
    {'name': 'Scallops',   'emoji': '🍤'},
    {'name': 'Mackerel',   'emoji': '🐟'},
    {'name': 'Anchovies',  'emoji': '🐟'},
  ],
  'Dairy': [
    {'name': 'Milk',            'emoji': '🥛'},
    {'name': 'Eggs',            'emoji': '🥚'},
    {'name': 'Butter',          'emoji': '🧈'},
    {'name': 'Cheddar Cheese',  'emoji': '🧀'},
    {'name': 'Mozzarella',      'emoji': '🧀'},
    {'name': 'Cream Cheese',    'emoji': '🧀'},
    {'name': 'Yogurt',          'emoji': '🥛'},
    {'name': 'Sour Cream',      'emoji': '🥛'},
    {'name': 'Heavy Cream',     'emoji': '🥛'},
    {'name': 'Parmesan',        'emoji': '🧀'},
    {'name': 'Feta Cheese',     'emoji': '🧀'},
    {'name': 'Ricotta',         'emoji': '🧀'},
    {'name': 'Whipped Cream',   'emoji': '🥛'},
    {'name': 'Condensed Milk',  'emoji': '🥛'},
    {'name': 'Kefir',           'emoji': '🥛'},
  ],
  'Bakery': [
    {'name': 'White Bread',   'emoji': '🍞'},
    {'name': 'Whole Wheat Bread', 'emoji': '🍞'},
    {'name': 'Baguette',      'emoji': '🥖'},
    {'name': 'Croissant',     'emoji': '🥐'},
    {'name': 'Bagel',         'emoji': '🥯'},
    {'name': 'Pita Bread',    'emoji': '🫓'},
    {'name': 'Tortillas',     'emoji': '🫓'},
    {'name': 'Muffins',       'emoji': '🧁'},
    {'name': 'Dinner Rolls',  'emoji': '🍞'},
    {'name': 'Sourdough',     'emoji': '🍞'},
    {'name': 'Rye Bread',     'emoji': '🍞'},
    {'name': 'Brioche',       'emoji': '🍞'},
    {'name': 'Pretzel',       'emoji': '🥨'},
    {'name': 'Donuts',        'emoji': '🍩'},
    {'name': 'Waffles',       'emoji': '🧇'},
    {'name': 'Pancake Mix',   'emoji': '🥞'},
  ],
  'Beverages': [
    {'name': 'Water',         'emoji': '💧'},
    {'name': 'Orange Juice',  'emoji': '🍊'},
    {'name': 'Apple Juice',   'emoji': '🍎'},
    {'name': 'Coffee',        'emoji': '☕'},
    {'name': 'Tea',           'emoji': '🍵'},
    {'name': 'Soda',          'emoji': '🥤'},
    {'name': 'Energy Drink',  'emoji': '⚡'},
    {'name': 'Milk',          'emoji': '🥛'},
    {'name': 'Sparkling Water','emoji': '💦'},
    {'name': 'Lemonade',      'emoji': '🍋'},
    {'name': 'Coconut Water', 'emoji': '🥥'},
    {'name': 'Sports Drink',  'emoji': '🏃'},
    {'name': 'Green Tea',     'emoji': '🍵'},
    {'name': 'Hot Chocolate', 'emoji': '☕'},
    {'name': 'Wine',          'emoji': '🍷'},
    {'name': 'Beer',          'emoji': '🍺'},
    {'name': 'Smoothie',      'emoji': '🥤'},
    {'name': 'Almond Milk',   'emoji': '🥛'},
  ],
  'Snacks': [
    {'name': 'Chips',          'emoji': '🥔'},
    {'name': 'Popcorn',        'emoji': '🍿'},
    {'name': 'Crackers',       'emoji': '🫙'},
    {'name': 'Pretzels',       'emoji': '🥨'},
    {'name': 'Nuts Mix',       'emoji': '🥜'},
    {'name': 'Almonds',        'emoji': '🥜'},
    {'name': 'Cashews',        'emoji': '🥜'},
    {'name': 'Granola Bar',    'emoji': '🍫'},
    {'name': 'Rice Cakes',     'emoji': '🍙'},
    {'name': 'Dried Fruit',    'emoji': '🍇'},
    {'name': 'Fruit Snacks',   'emoji': '🍬'},
    {'name': 'Peanut Butter',  'emoji': '🥜'},
    {'name': 'Hummus',         'emoji': '🫙'},
    {'name': 'Cheese Sticks',  'emoji': '🧀'},
    {'name': 'Protein Bar',    'emoji': '💪'},
    {'name': 'Trail Mix',      'emoji': '🌰'},
  ],
  'Frozen': [
    {'name': 'Ice Cream',       'emoji': '🍦'},
    {'name': 'Frozen Pizza',    'emoji': '🍕'},
    {'name': 'Frozen Fries',    'emoji': '🍟'},
    {'name': 'Frozen Peas',     'emoji': '🟢'},
    {'name': 'Frozen Corn',     'emoji': '🌽'},
    {'name': 'Frozen Berries',  'emoji': '🫐'},
    {'name': 'Frozen Shrimp',   'emoji': '🍤'},
    {'name': 'Frozen Chicken',  'emoji': '🍗'},
    {'name': 'Frozen Waffles',  'emoji': '🧇'},
    {'name': 'Sorbet',          'emoji': '🍧'},
    {'name': 'Frozen Burrito',  'emoji': '🌯'},
    {'name': 'Frozen Lasagna',  'emoji': '🍝'},
    {'name': 'Frozen Fish',     'emoji': '🐟'},
    {'name': 'Popsicles',       'emoji': '🧊'},
  ],
  'Grains': [
    {'name': 'White Rice',     'emoji': '🍚'},
    {'name': 'Brown Rice',     'emoji': '🍚'},
    {'name': 'Oats',           'emoji': '🌾'},
    {'name': 'Quinoa',         'emoji': '🌾'},
    {'name': 'Barley',         'emoji': '🌾'},
    {'name': 'Bulgur',         'emoji': '🌾'},
    {'name': 'Couscous',       'emoji': '🌾'},
    {'name': 'Corn Meal',      'emoji': '🌽'},
    {'name': 'Breadcrumbs',    'emoji': '🍞'},
    {'name': 'Flour',          'emoji': '🌾'},
    {'name': 'Cornstarch',     'emoji': '🌽'},
    {'name': 'Wheat Bran',     'emoji': '🌾'},
  ],
  'Condiments': [
    {'name': 'Ketchup',          'emoji': '🍅'},
    {'name': 'Mustard',          'emoji': '💛'},
    {'name': 'Mayonnaise',       'emoji': '🫙'},
    {'name': 'Hot Sauce',        'emoji': '🌶️'},
    {'name': 'Soy Sauce',        'emoji': '🫙'},
    {'name': 'Barbecue Sauce',   'emoji': '🍖'},
    {'name': 'Ranch Dressing',   'emoji': '🫙'},
    {'name': 'Honey Mustard',    'emoji': '🍯'},
    {'name': 'Salsa',            'emoji': '🍅'},
    {'name': 'Guacamole',        'emoji': '🥑'},
    {'name': 'Relish',           'emoji': '🫙'},
    {'name': 'Sriracha',         'emoji': '🌶️'},
    {'name': 'Worcestershire',   'emoji': '🫙'},
    {'name': 'Vinegar',          'emoji': '🫙'},
    {'name': 'Olive Tapenade',   'emoji': '🫒'},
  ],
  'Canned Goods': [
    {'name': 'Canned Tomatoes',  'emoji': '🥫'},
    {'name': 'Canned Tuna',      'emoji': '🥫'},
    {'name': 'Canned Beans',     'emoji': '🥫'},
    {'name': 'Canned Corn',      'emoji': '🥫'},
    {'name': 'Canned Peas',      'emoji': '🥫'},
    {'name': 'Canned Soup',      'emoji': '🥫'},
    {'name': 'Tomato Paste',     'emoji': '🥫'},
    {'name': 'Coconut Milk',     'emoji': '🥫'},
    {'name': 'Chickpeas',        'emoji': '🥫'},
    {'name': 'Kidney Beans',     'emoji': '🥫'},
    {'name': 'Lentils',          'emoji': '🥫'},
    {'name': 'Canned Peaches',   'emoji': '🥫'},
    {'name': 'Canned Pineapple', 'emoji': '🥫'},
    {'name': 'Sardines',         'emoji': '🥫'},
    {'name': 'Canned Mushrooms', 'emoji': '🥫'},
  ],
  'Spices': [
    {'name': 'Salt',          'emoji': '🧂'},
    {'name': 'Black Pepper',  'emoji': '⚫'},
    {'name': 'Cumin',         'emoji': '🌿'},
    {'name': 'Paprika',       'emoji': '🌶️'},
    {'name': 'Turmeric',      'emoji': '🟡'},
    {'name': 'Cinnamon',      'emoji': '🌿'},
    {'name': 'Oregano',       'emoji': '🌿'},
    {'name': 'Basil',         'emoji': '🌿'},
    {'name': 'Thyme',         'emoji': '🌿'},
    {'name': 'Bay Leaves',    'emoji': '🍃'},
    {'name': 'Chili Flakes',  'emoji': '🌶️'},
    {'name': 'Garlic Powder', 'emoji': '🧄'},
    {'name': 'Onion Powder',  'emoji': '🧅'},
    {'name': 'Ginger',        'emoji': '🫚'},
    {'name': 'Cardamom',      'emoji': '🌿'},
    {'name': 'Nutmeg',        'emoji': '🌰'},
    {'name': 'Coriander',     'emoji': '🌿'},
    {'name': 'Cloves',        'emoji': '🌿'},
  ],
  'Oils & Fats': [
    {'name': 'Olive Oil',      'emoji': '🫒'},
    {'name': 'Vegetable Oil',  'emoji': '🫙'},
    {'name': 'Coconut Oil',    'emoji': '🥥'},
    {'name': 'Butter',         'emoji': '🧈'},
    {'name': 'Margarine',      'emoji': '🧈'},
    {'name': 'Canola Oil',     'emoji': '🫙'},
    {'name': 'Sesame Oil',     'emoji': '🫙'},
    {'name': 'Avocado Oil',    'emoji': '🥑'},
    {'name': 'Ghee',           'emoji': '🧈'},
    {'name': 'Lard',           'emoji': '🫙'},
    {'name': 'Sunflower Oil',  'emoji': '🌻'},
  ],
  'Sweets': [
    {'name': 'Chocolate Bar',  'emoji': '🍫'},
    {'name': 'Candy',          'emoji': '🍬'},
    {'name': 'Gummy Bears',    'emoji': '🐻'},
    {'name': 'Lollipop',       'emoji': '🍭'},
    {'name': 'Marshmallows',   'emoji': '☁️'},
    {'name': 'Cookies',        'emoji': '🍪'},
    {'name': 'Cake',           'emoji': '🎂'},
    {'name': 'Brownie',        'emoji': '🍫'},
    {'name': 'Honey',          'emoji': '🍯'},
    {'name': 'Jam',            'emoji': '🍓'},
    {'name': 'Maple Syrup',    'emoji': '🍁'},
    {'name': 'Nutella',        'emoji': '🍫'},
    {'name': 'Ice Cream',      'emoji': '🍨'},
    {'name': 'Pudding',        'emoji': '🍮'},
    {'name': 'Caramel',        'emoji': '🍯'},
    {'name': 'Jelly',          'emoji': '🫙'},
  ],
  'Baby Food': [
    {'name': 'Baby Formula',   'emoji': '🍼'},
    {'name': 'Pureed Veggies', 'emoji': '🥣'},
    {'name': 'Pureed Fruits',  'emoji': '🥣'},
    {'name': 'Baby Cereal',    'emoji': '🌾'},
    {'name': 'Teething Snacks','emoji': '🍪'},
    {'name': 'Baby Yogurt',    'emoji': '🥛'},
    {'name': 'Baby Juice',     'emoji': '🧃'},
    {'name': 'Rice Puffs',     'emoji': '🌾'},
    {'name': 'Baby Pouches',   'emoji': '🥣'},
    {'name': 'Baby Water',     'emoji': '💧'},
  ],
  'Health': [
    {'name': 'Protein Powder', 'emoji': '💪'},
    {'name': 'Vitamins',       'emoji': '💊'},
    {'name': 'Fiber Supplement','emoji': '🌿'},
    {'name': 'Probiotics',     'emoji': '🦠'},
    {'name': 'Fish Oil',       'emoji': '🐟'},
    {'name': 'Collagen',       'emoji': '✨'},
    {'name': 'Multivitamin',   'emoji': '💊'},
    {'name': 'Chia Seeds',     'emoji': '🌱'},
    {'name': 'Flax Seeds',     'emoji': '🌱'},
    {'name': 'Whey Protein',   'emoji': '💪'},
    {'name': 'Herbal Tea',     'emoji': '🍵'},
    {'name': 'Apple Cider Vinegar', 'emoji': '🍎'},
  ],
  'Cleaning': [
    {'name': 'Dish Soap',        'emoji': '🧴'},
    {'name': 'Laundry Detergent','emoji': '🧺'},
    {'name': 'All-Purpose Spray','emoji': '🧹'},
    {'name': 'Bleach',           'emoji': '🫙'},
    {'name': 'Floor Cleaner',    'emoji': '🧹'},
    {'name': 'Toilet Cleaner',   'emoji': '🚽'},
    {'name': 'Glass Cleaner',    'emoji': '🪟'},
    {'name': 'Sponges',          'emoji': '🧽'},
    {'name': 'Paper Towels',     'emoji': '🧻'},
    {'name': 'Trash Bags',       'emoji': '🗑️'},
    {'name': 'Fabric Softener',  'emoji': '🌸'},
    {'name': 'Dryer Sheets',     'emoji': '🌸'},
    {'name': 'Mop',              'emoji': '🧹'},
    {'name': 'Broom',            'emoji': '🧹'},
  ],
  'Personal Care': [
    {'name': 'Shampoo',          'emoji': '🧴'},
    {'name': 'Conditioner',      'emoji': '🧴'},
    {'name': 'Body Wash',        'emoji': '🧼'},
    {'name': 'Soap Bar',         'emoji': '🧼'},
    {'name': 'Toothpaste',       'emoji': '🦷'},
    {'name': 'Toothbrush',       'emoji': '🪥'},
    {'name': 'Deodorant',        'emoji': '✨'},
    {'name': 'Moisturizer',      'emoji': '🧴'},
    {'name': 'Sunscreen',        'emoji': '☀️'},
    {'name': 'Razor',            'emoji': '🪒'},
    {'name': 'Shaving Cream',    'emoji': '🧴'},
    {'name': 'Facial Cleanser',  'emoji': '💆'},
    {'name': 'Lip Balm',         'emoji': '💋'},
    {'name': 'Hand Sanitizer',   'emoji': '🤲'},
    {'name': 'Tissue',           'emoji': '🧻'},
    {'name': 'Cotton Pads',      'emoji': '☁️'},
  ],
  'Pet Food': [
    {'name': 'Dog Food (Dry)',   'emoji': '🐕'},
    {'name': 'Dog Food (Wet)',   'emoji': '🐕'},
    {'name': 'Cat Food (Dry)',   'emoji': '🐈'},
    {'name': 'Cat Food (Wet)',   'emoji': '🐈'},
    {'name': 'Dog Treats',       'emoji': '🦴'},
    {'name': 'Cat Treats',       'emoji': '🐾'},
    {'name': 'Bird Seed',        'emoji': '🐦'},
    {'name': 'Fish Food',        'emoji': '🐠'},
    {'name': 'Rabbit Pellets',   'emoji': '🐇'},
    {'name': 'Hamster Food',     'emoji': '🐹'},
    {'name': 'Pet Milk',         'emoji': '🥛'},
    {'name': 'Dental Chews',     'emoji': '🦷'},
  ],
  'Breakfast': [
    {'name': 'Cereal',           'emoji': '🥣'},
    {'name': 'Oatmeal',          'emoji': '🌾'},
    {'name': 'Granola',          'emoji': '🌾'},
    {'name': 'Pancake Mix',      'emoji': '🥞'},
    {'name': 'Waffle Mix',       'emoji': '🧇'},
    {'name': 'Orange Juice',     'emoji': '🍊'},
    {'name': 'Maple Syrup',      'emoji': '🍁'},
    {'name': 'Jam',              'emoji': '🍓'},
    {'name': 'Peanut Butter',    'emoji': '🥜'},
    {'name': 'Yogurt',           'emoji': '🥛'},
    {'name': 'Eggs',             'emoji': '🥚'},
    {'name': 'Bacon',            'emoji': '🥓'},
    {'name': 'Bagel',            'emoji': '🥯'},
    {'name': 'English Muffin',   'emoji': '🍞'},
    {'name': 'Breakfast Bar',    'emoji': '🍫'},
  ],
  'Pasta & Rice': [
    {'name': 'Spaghetti',        'emoji': '🍝'},
    {'name': 'Penne',            'emoji': '🍝'},
    {'name': 'Fusilli',          'emoji': '🍝'},
    {'name': 'Fettuccine',       'emoji': '🍝'},
    {'name': 'Lasagna Sheets',   'emoji': '🍝'},
    {'name': 'Macaroni',         'emoji': '🧀'},
    {'name': 'White Rice',       'emoji': '🍚'},
    {'name': 'Brown Rice',       'emoji': '🍚'},
    {'name': 'Basmati Rice',     'emoji': '🍚'},
    {'name': 'Jasmine Rice',     'emoji': '🍚'},
    {'name': 'Arborio Rice',     'emoji': '🍚'},
    {'name': 'Noodles',          'emoji': '🍜'},
    {'name': 'Rice Noodles',     'emoji': '🍜'},
    {'name': 'Vermicelli',       'emoji': '🍜'},
    {'name': 'Egg Noodles',      'emoji': '🍜'},
  ],
  'Deli': [
    {'name': 'Turkey Slices',    'emoji': '🍖'},
    {'name': 'Ham Slices',       'emoji': '🍖'},
    {'name': 'Salami',           'emoji': '🍖'},
    {'name': 'Pepperoni',        'emoji': '🍕'},
    {'name': 'Roast Beef',       'emoji': '🥩'},
    {'name': 'Pastrami',         'emoji': '🥩'},
    {'name': 'Bologna',          'emoji': '🍖'},
    {'name': 'Swiss Cheese',     'emoji': '🧀'},
    {'name': 'Provolone',        'emoji': '🧀'},
    {'name': 'Chicken Strips',   'emoji': '🍗'},
    {'name': 'Smoked Salmon',    'emoji': '🐟'},
    {'name': 'Hummus',           'emoji': '🫙'},
    {'name': 'Coleslaw',         'emoji': '🥗'},
    {'name': 'Potato Salad',     'emoji': '🥗'},
  ],
  'Other': [
    {'name': 'Cooking Wine',    'emoji': '🍷'},
    {'name': 'Baking Powder',   'emoji': '🫙'},
    {'name': 'Baking Soda',     'emoji': '🫙'},
    {'name': 'Yeast',           'emoji': '🌾'},
    {'name': 'Gelatin',         'emoji': '🫙'},
    {'name': 'Vanilla Extract', 'emoji': '🫙'},
    {'name': 'Food Coloring',   'emoji': '🎨'},
    {'name': 'Cocoa Powder',    'emoji': '🍫'},
    {'name': 'Powdered Sugar',  'emoji': '🍬'},
    {'name': 'Brown Sugar',     'emoji': '🍯'},
    {'name': 'White Sugar',     'emoji': '🍬'},
    {'name': 'Aluminum Foil',   'emoji': '🪙'},
    {'name': 'Plastic Wrap',    'emoji': '🪙'},
    {'name': 'Parchment Paper', 'emoji': '📄'},
    {'name': 'Zip Lock Bags',   'emoji': '🛍️'},
    {'name': 'Toothpicks',      'emoji': '🪥'},
  ],
};

/// Full-screen page showing all items for a given grocery category.
/// Tapping an item opens [showAddItemDetailsSheet] and calls [onItemAdded]
/// with the resulting data map.
class CategoryItemsPage extends StatefulWidget {
  final String category;
  final IconData categoryIcon;
  final Color accent;
  final Future<void> Function(Map<String, dynamic> itemData) onItemAdded;

  const CategoryItemsPage({
    Key? key,
    required this.category,
    required this.categoryIcon,
    required this.accent,
    required this.onItemAdded,
  }) : super(key: key);

  @override
  State<CategoryItemsPage> createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  String _search = '';
  // Track per-item selected priority in the UI (0 = Normal, 1 = Urgent)
  final Map<String, int> _selectedPriorities = {};

  List<Map<String, dynamic>> get _filtered {
    final all = _categoryItems[widget.category] ?? [];
    if (_search.isEmpty) return all;
    return all
        .where((item) =>
            (item['name'] as String).toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  Future<void> _onItemTap(Map<String, dynamic> item) async {
    final name = item['name'] as String;
    final result = await showAddItemDetailsSheet(
      context,
      itemName: name,
      categoryLabel: widget.category,
      accent: widget.accent,
    );
    if (result != null && mounted) {
      await widget.onItemAdded(result);
      if (mounted) Navigator.of(context).pop(); // go back to ListDetailsPage
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                color: widget.accent.withAlpha(31),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.categoryIcon, size: 18, color: widget.accent),
            ),
            const SizedBox(width: 10),
            Text(
              widget.category,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search ${widget.category.toLowerCase()}…',
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: widget.accent, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Count ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${items.length} item${items.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Items grid ─────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No items found',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final item = items[i];
                            final name = item['name'] as String;
                            final emoji = item['emoji'] as String;
                            final priority = _selectedPriorities[name] ?? 0;
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(color: widget.accent.withAlpha(26), shape: BoxShape.circle),
                                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                                ),
                                title: Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                subtitle: Text(widget.category, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Priority toggle
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedPriorities[name] = priority == 0 ? 1 : 0;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: priority == 1 ? Colors.redAccent.withAlpha(26) : widget.accent.withAlpha(18),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: priority == 1 ? Colors.redAccent.withAlpha(80) : widget.accent.withAlpha(60)),
                                        ),
                                        child: Row(
                                          children: [
                                            if (priority == 1) const Icon(Icons.priority_high, size: 16, color: Colors.redAccent) else const SizedBox.shrink(),
                                            const SizedBox(width: 6),
                                            Text(priority == 1 ? 'Urgent' : 'Normal', style: TextStyle(fontSize: 12, color: priority == 1 ? Colors.redAccent : widget.accent)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _onItemTap(item),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.accent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        minimumSize: const Size(56, 36),
                                      ),
                                      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
          ),
        ],
      ),
    );
  }
}

// _ItemCard removed — category view now uses a list with inline controls.
