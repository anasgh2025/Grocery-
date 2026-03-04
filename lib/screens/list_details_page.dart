// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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
        // Removed 3-dots menu (PopupMenuButton)
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Failed to load items.\n$_error', textAlign: TextAlign.center))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.12,
                    ),
                    itemCount: _items.length + 1, // +1 for Add New Item card
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Add New Item card always first
                        return GestureDetector(
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
                              _fetchItems();
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
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 32, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Add New Item', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      // Item card (shifted by -1)
                      final item = _items[index - 1];
                      final isChecked = item['checked'] == true;
                      // Determine background asset for special categories
                      // No background image for item card
                      return GestureDetector(
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
                        onLongPress: () async {
                          final shouldDelete = await showDialog<bool>(
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
                          if (shouldDelete == true) {
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
                        child: SizedBox(
                          height: 140, // Increased height for long names
                          child: Stack(
                            children: [
                              // Card shadow/background
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.06),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              // Foreground content only (no background image)
                              Container(
                                decoration: BoxDecoration(
                                  color: isChecked ? Colors.grey[300] : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getEmojiForItem(item['name']?.toString()),
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            item['name'] ?? '',
                                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                        if (isChecked)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0, top: 2.0),
                                            child: Icon(Icons.check_circle, color: Colors.green, size: 22),
                                          ),
                                      ],
                                    ),
                                    const Spacer(),
                                    if (item['qty'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 2.0, bottom: 2.0),
                                        child: Text(
                                          'Qty: ${item['qty']}',
                                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
