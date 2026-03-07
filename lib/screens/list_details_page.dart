// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/categories_page.dart';
import '../services/api_service.dart';
import '../widgets/box_styles.dart';

class ListDetailsPage extends StatefulWidget {
  final dynamic list;
  final Color accent;
  final Function? onItemsChanged;
  const ListDetailsPage({Key? key, required this.list, required this.accent, this.onItemsChanged}) : super(key: key);

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
}

class _ListDetailsPageState extends State<ListDetailsPage> {
  // Map item names to logical grocery categories for robust grouping
  static const Map<String, String> _itemCategoryMap = {
    'banana': 'fruits',
    'grape': 'fruits',
    'grapes': 'fruits',
    'apple': 'fruits',
    'orange': 'fruits',
    'pear': 'fruits',
    'peach': 'fruits',
    'kiwi': 'fruits',
    'pineapple': 'fruits',
    'watermelon': 'fruits',
    'lemon': 'fruits',
    'strawberry': 'fruits',
    'avocado': 'fruits',
    'milk': 'dairy',
    'cheese': 'dairy',
    'egg': 'dairy',
    'butter': 'dairy',
    'yogurt': 'dairy',
    'croissant': 'bakery',
    'bread': 'bakery',
    'cake': 'bakery',
    'cookie': 'bakery',
    'carrot': 'vegetables',
    'potato': 'vegetables',
    'tomato': 'vegetables',
    'lettuce': 'vegetables',
    'onion': 'vegetables',
    'corn': 'vegetables',
    'cucumber': 'vegetables',
    'pepper': 'vegetables',
    'mushroom': 'vegetables',
    'garlic': 'vegetables',
    'beans': 'vegetables',
    'broccoli': 'vegetables',
    'eggplant': 'vegetables',
    'pumpkin': 'vegetables',
    'cabbage': 'vegetables',
    'spinach': 'vegetables',
    // Add more as needed
  };

  String _getCategoryForItem(Map<String, dynamic> item) {
    final backendCat = (item['category'] ?? '').toString().toLowerCase();
    if (backendCat.isNotEmpty) return backendCat;
    final name = (item['name'] ?? '').toString().toLowerCase();
    for (final entry in _itemCategoryMap.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return 'other';
  }
  String _searchQuery = '';
  List<Map<String, dynamic>> _suggestions = [];
  bool _suggestionsLoading = false;
  // Map item names to emoji for display
  static const Map<String, String> _itemEmojiMap = {
    'apple': '🍎',
    'orange': '🍊',
    'banana': '🍌',
    'grape': '🍇',
    'carrot': '🥕',
    'bread': '🍞',
    'cheese': '🧀',
    'milk': '🥛',
    'egg': '🥚',
    'chicken': '🍗',
    'fish': '🐟',
    'beef': '🥩',
    'rice': '🍚',
    'potato': '🥔',
    'tomato': '🍅',
    'lettuce': '🥬',
    'watermelon': '🍉',
    'lemon': '🍋',
    'strawberry': '🍓',
    'avocado': '🥑',
    'onion': '🧅',
    'corn': '🌽',
    'cucumber': '🥒',
    'pepper': '🫑',
    'mushroom': '🍄',
  // 'shrimp': '🦐', // removed duplicate
    'garlic': '🧄',
    'pear': '🍐',
    'peach': '🍑',
    'kiwi': '🥝',
    'pineapple': '🍍',
    'chili': '🌶️',
    'bacon': '🥓',
    'sausage': '🌭',
    'cookie': '🍪',
    'cake': '🍰',
    'ice': '🍦',
    'honey': '🍯',
    'beans': '🫘',
    'broccoli': '🥦',
    'eggplant': '🍆',
    'pumpkin': '🎃',
    'cabbage': '🥬',
    'spinach': '🥬',
    'basil': '🌿',
    'mint': '🌿',
    'sushi': '🍣',
    'shrimp': '🦐',
    'crab': '🦀',
    'lobster': '🦞',
    'salmon': '🐟',
    'tuna': '🐟',
    'turkey': '🦃',
    'duck': '🦆',
    'lamb': '🐑',
    'pasta': '🍝',
    'noodle': '🍜',
    'pizza': '🍕',
    'burger': '🍔',
    'sandwich': '🥪',
    'fries': '🍟',
    'soup': '🍲',
    'salad': '🥗',
    'popcorn': '🍿',
    'chocolate': '🍫',
    'candy': '🍬',
    'donut': '🍩',
    'coffee': '☕',
    'tea': '🍵',
    'juice': '🧃',
    'soda': '🥤',
    'water': '💧',
    // Add more as needed
  };

  String _getEmojiForItem(String? name) {
    if (name == null) return '🛒';
    final lower = name.toLowerCase();
    for (final entry in _itemEmojiMap.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return '🛒';
  }
  final TextEditingController _addItemController = TextEditingController();
  final ApiService _api = ApiService();
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  // Fetch suggestions from backend
  Future<void> _fetchSuggestions(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
        _suggestionsLoading = false;
      });
      return;
    }
    setState(() {
      _suggestionsLoading = true;
    });
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final suggestions = await _api.searchItemSuggestions(query, lang: lang);
      setState(() {
        _suggestions = suggestions;
        _suggestionsLoading = false;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _suggestionsLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems({bool notifyParent = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.fetchListItems(widget.list.id);
      setState(() {
        _items = items;
        _loading = false;
      });
      if (notifyParent && widget.onItemsChanged != null) {
        widget.onItemsChanged!();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _addItemController.dispose();
    super.dispose();
  }

  void _shareList() {
    final listName = widget.list.name;
    final items = _items;
    final itemsText = items.isNotEmpty
        ? items.map((item) {
            final name = item['name'] ?? '';
            final qty = item['qty'] != null ? ' (Qty: ${item['qty']})' : '';
            final price = item['price'] ?? 0;
            final checked = item['checked'] == true ? '✔️' : '❌';
            return '• $name$qty [Price: $price] [$checked]';
          }).join('\n')
        : 'No items in the list.';
    final shareText = 'Here is the list of $listName\n$itemsText\n\nThank you for using the app';
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      Share.share(
        shareText,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    } else {
      Share.share(shareText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Calculate checked/total items
    final int total = _items.length;
    final int checked = _items.where((item) => item['checked'] == true).length;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.list.name ?? '', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (total > 0)
              Text('$checked/$total items checked', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share List',
            onPressed: _shareList,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search field at the top
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                    _fetchSuggestions(val);
                  },
                ),
                if (_suggestionsLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, idx) {
                        final s = _suggestions[idx];
                        final displayName = Localizations.localeOf(context).languageCode == 'ar'
                            ? (s['name_ar'] ?? s['name'] ?? '')
                            : (s['name'] ?? '');
                        return ListTile(
                          leading: Text(s['emoji'] ?? '🛒', style: const TextStyle(fontSize: 22)),
                          title: Text(displayName),
                          onTap: () async {
                            // Check if item already exists in _items
                            final existingItem = _items.firstWhere(
                              (item) => (item['name'] ?? '').toString().toLowerCase() == (s['name'] ?? '').toString().toLowerCase(),
                              orElse: () => null,
                            );
                            if (existingItem != null) {
                              if (existingItem['checked'] == true) {
                                // If item is already ticked, show info dialog only
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Item already completed'),
                                    content: const Text('This item is already in your list and marked as completed.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                              int currentQty = (existingItem['qty'] ?? 1) is int ? (existingItem['qty'] ?? 1) : int.tryParse(existingItem['qty'].toString()) ?? 1;
                              final shouldIncrease = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Item already exists'),
                                  content: Text('This item is already in your list. Do you want to increase the quantity?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Increase Qty'),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldIncrease == true) {
                                await _api.updateListItem(
                                  widget.list.id,
                                  existingItem['id'],
                                  {'qty': currentQty + 1},
                                );
                                setState(() {
                                  _searchQuery = '';
                                  _suggestions = [];
                                });
                                _fetchItems(notifyParent: true);
                              }
                              return;
                            }
                            await _api.addListItem(widget.list.id, {
                              'name': s['name'],
                              'qty': 1,
                            });
                            setState(() {
                              _searchQuery = '';
                              _suggestions = [];
                            });
                            _fetchItems(notifyParent: true);
                          },
                        );
                      },
                    ),
                  ),
                if (!_suggestionsLoading && _searchQuery.length >= 3 && _suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'No data match',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Failed to load items.\n$_error', textAlign: TextAlign.center))
                      : Builder(
                          builder: (context) {
                            final filteredItems = _searchQuery.isEmpty
                                ? _items.toList()
                                : _items.where((item) {
                                    final name = (item['name'] ?? '').toString().toLowerCase();
                                    return name.contains(_searchQuery.toLowerCase());
                                  }).toList();
                            // Sort: unticked items by category, then checked items
                            // Define a logical category order for grouping
                            const categoryOrder = [
                              'fruits',
                              'fruit',
                              'vegetables',
                              'vegetable',
                              'dairy',
                              'meat',
                              'bakery',
                              'beverages',
                              'snacks',
                              'seafood',
                              'frozen',
                              'spices',
                              'condiments',
                              'other',
                            ];
                            int getCategoryIndex(String cat) {
                              final idx = categoryOrder.indexWhere((c) => cat == c);
                              return idx == -1 ? categoryOrder.length : idx;
                            }
                            filteredItems.sort((a, b) {
                              final aChecked = a['checked'] == true ? 1 : 0;
                              final bChecked = b['checked'] == true ? 1 : 0;
                              if (aChecked != bChecked) {
                                return aChecked.compareTo(bChecked);
                              }
                              // Both unticked or both checked: if unticked, sort by logical category order only
                              if (aChecked == 0 && bChecked == 0) {
                                final aCat = _getCategoryForItem(a);
                                final bCat = _getCategoryForItem(b);
                                final aIdx = getCategoryIndex(aCat);
                                final bIdx = getCategoryIndex(bCat);
                                return aIdx.compareTo(bIdx);
                              }
                              // Both checked: preserve order
                              return 0;
                            });
                            return ListView.builder(
                              itemCount: filteredItems.length + 1, // +1 for Add New Item card
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // Add New Item card always first
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => CategoriesPage(
                                              accent: widget.accent,
                                              listId: widget.list.id,
                                            ),
                                          ),
                                        );
                                        if (!mounted) return;
                                        if (result == true) {
                                          _fetchItems(notifyParent: true);
                                        }
                                      },
                                      child: CustomPaint(
                                        painter: DashedRRectPainter(
                                          color: Colors.grey.shade300,
                                          strokeWidth: 1.6,
                                          radius: 10.0,
                                          dashWidth: 6.0,
                                          dashSpace: 4.0,
                                        ),
                                        child: Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_circle_outline, size: 28, color: Colors.grey),
                                                SizedBox(width: 10),
                                                Text('Add New Item', style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                // Item card (shifted by -1)
                                final item = filteredItems[index - 1];
                                final isChecked = item['checked'] == true;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: isChecked
                                      ? Container(
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color.fromRGBO(0, 0, 0, 0.06),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                _getEmojiForItem(item['name']?.toString()),
                                                style: const TextStyle(fontSize: 24),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  item['name'] ?? '',
                                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                                                  softWrap: true,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                              if (item['qty'] != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10.0),
                                                  child: Text(
                                                    'Qty: ${item['qty']}',
                                                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700], decoration: TextDecoration.underline),
                                                  ),
                                                ),
                                              const Padding(
                                                padding: EdgeInsets.only(left: 10.0),
                                                child: Icon(Icons.check_circle, color: Colors.green, size: 22),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Dismissible(
                                          key: ValueKey(item['id']),
                                          direction: DismissDirection.horizontal, // Allow both left and right
                                          background: Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                            color: Colors.red,
                                            child: const Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.white),
                                                SizedBox(width: 8),
                                                Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                          secondaryBackground: Builder(
                                            builder: (context) {
                                              return Container(
                                                alignment: Alignment.centerRight,
                                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                                color: Colors.blue,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        await showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: const Text('Add Photo'),
                                                            content: const Text('Photo upload feature coming soon.'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.of(context).pop(),
                                                                child: const Text('OK'),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      child: const Icon(Icons.photo_camera, color: Colors.white, size: 28),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        await showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: const Text('Favorite'),
                                                            content: const Text('Favorite feature coming soon.'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.of(context).pop(),
                                                                child: const Text('OK'),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      child: const Icon(Icons.star, color: Colors.orange, size: 28),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          confirmDismiss: (direction) async {
                                            if (direction == DismissDirection.startToEnd) {
                                              // Delete
                                              return await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Delete Item'),
                                                  content: Text('Are you sure you want to delete "${item['name']}"?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                      ),
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (direction == DismissDirection.endToStart) {
                                              // Prevent dismiss, icons are now clickable
                                              return false;
                                            }
                                            return false;
                                          },
                                          onDismissed: (direction) async {
                                            if (direction == DismissDirection.startToEnd) {
                                              try {
                                                await _api.deleteListItem(widget.list.id, item['id']);
                                                if (!mounted) return;
                                                _fetchItems(notifyParent: true);
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Failed to delete item: $e')),
                                                );
                                              }
                                            }
                                          },
                                          child: GestureDetector(
                                            onTap: () async {
                                              try {
                                                await _api.updateListItem(
                                                  widget.list.id,
                                                  item['id'],
                                                  {'checked': !isChecked},
                                                );
                                                if (!mounted) return;
                                                _fetchItems(notifyParent: true);
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Failed to update item: $e')),
                                                );
                                              }
                                            },
                                            child: Container(
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: isChecked ? Colors.grey[300] : Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _getEmojiForItem(item['name']?.toString()),
                                                    style: const TextStyle(fontSize: 24),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      item['name'] ?? '',
                                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                  if (item['qty'] != null)
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10.0),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          int currentQty = (item['qty'] ?? 1) is int ? (item['qty'] ?? 1) : int.tryParse(item['qty'].toString()) ?? 1;
                                                          int newQty = currentQty;
                                                          final result = await showDialog<int>(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: const Text('Change Quantity'),
                                                                content: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    IconButton(
                                                                      icon: const Icon(Icons.remove_circle_outline),
                                                                      onPressed: newQty > 1
                                                                          ? () {
                                                                              if (newQty > 1) {
                                                                                newQty--;
                                                                              }
                                                                              (context as Element).markNeedsBuild();
                                                                            }
                                                                          : null,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                                      child: Text('$newQty', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                                    ),
                                                                    IconButton(
                                                                      icon: const Icon(Icons.add_circle_outline),
                                                                      onPressed: () {
                                                                        newQty++;
                                                                        (context as Element).markNeedsBuild();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () => Navigator.of(context).pop(),
                                                                    child: const Text('Cancel'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () => Navigator.of(context).pop(newQty),
                                                                    child: const Text('Update'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                          if (result != null && result != currentQty) {
                                                            await _api.updateListItem(
                                                              widget.list.id,
                                                              item['id'],
                                                              {'qty': result},
                                                            );
                                                            _fetchItems(notifyParent: true);
                                                          }
                                                        },
                                                        child: Text(
                                                          'Qty: ${item['qty']}',
                                                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700], decoration: TextDecoration.underline),
                                                        ),
                                                      ),
                                                    ),
                                                  if (isChecked)
                                                    const Padding(
                                                      padding: EdgeInsets.only(left: 10.0),
                                                      child: Icon(Icons.check_circle, color: Colors.green, size: 22),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
