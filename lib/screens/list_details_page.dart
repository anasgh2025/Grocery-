import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/footer_menu.dart';
import 'categories_page.dart';
import '../services/api_service.dart';

// Dashed border painter for the 'Create New Item' card
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = (distance + dashWidth).clamp(0.0, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;


  }


class ListDetailsPage extends StatefulWidget {
  final dynamic list;
  final Color accent;
  final Function? onItemsChanged;
  const ListDetailsPage({Key? key, required this.list, required this.accent, this.onItemsChanged}) : super(key: key);

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
  

}

class _ListDetailsPageState extends State<ListDetailsPage> {

  Future<void> _refreshListItems() async {
    try {
      final api = ApiService();
      final items = await api.fetchListItems(widget.list.id);
      setState(() {
        widget.list.listItems = items;
      });
    } catch (e) {
      // Optionally show error
      debugPrint('Failed to refresh items: $e');
    }
  }
  final TextEditingController _searchController = TextEditingController();
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _suggestions = [];
  bool _loadingSuggestions = false;

  List<Map<String, dynamic>> get untickedItems {
    final items = widget.list.listItems;
    if (items == null) return [];
    return List<Map<String, dynamic>>.from(items.where((item) => item is Map && (item['checked'] != true)));
  }

  List<Map<String, dynamic>> get checkedItems {
    final items = widget.list.listItems;
    if (items == null) return [];
    return List<Map<String, dynamic>>.from(items.where((item) => item is Map && (item['checked'] == true)));
  }

  Map<String, List<Map<String, dynamic>>> get groupedUntickedItems {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in untickedItems) {
      final cat = (item['category'] is String && (item['category'] as String).isNotEmpty)
          ? item['category'] as String
          : 'Other';
      grouped.putIfAbsent(cat, () => []).add(item);
    }
    // Logical group order
    const logicalOrder = [
      'Fruit', 'Vegetable', 'Veg', 'Meat', 'Dairy', 'Bakery', 'Beverage', 'Pantry', 'Frozen', 'Snacks', 'Other'
    ];
    final keys = grouped.keys.toList();
    keys.sort((a, b) {
      final ia = logicalOrder.indexWhere((cat) => a.toLowerCase().contains(cat.toLowerCase()));
      final ib = logicalOrder.indexWhere((cat) => b.toLowerCase().contains(cat.toLowerCase()));
      if (ia == -1 && ib == -1) return a.compareTo(b); // both not found, fallback alpha
      if (ia == -1) return 1; // a not found, b found
      if (ib == -1) return -1; // b not found, a found
      return ia.compareTo(ib);
    });
    final Map<String, List<Map<String, dynamic>>> sortedGrouped = {};
    for (final k in keys) {
      sortedGrouped[k] = grouped[k]!;
    }
    return sortedGrouped;
  }

  void _onSearchChanged(String value) async {
    if (value.length < 3) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }
    setState(() {
      _showSuggestions = true;
      _loadingSuggestions = true;
    });
    try {
      final api = ApiService();
      final results = await api.searchItemSuggestions(value);
      setState(() {
        _suggestions = results;
        _loadingSuggestions = false;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _loadingSuggestions = false;
      });
      debugPrint('Failed to fetch suggestions: $e');
    }
  }

  void _onTapSuggestion(Map<String, dynamic> suggestion) async {
    try {
      final api = ApiService();
      // Always add emoji if present, fallback to 🛒
      final emoji = (suggestion['emoji'] is String && (suggestion['emoji'] as String).isNotEmpty)
          ? suggestion['emoji'] as String
          : '🛒';
      final itemToAdd = Map<String, dynamic>.from(suggestion);
      itemToAdd['emoji'] = emoji;
      await api.addListItem(widget.list.id, itemToAdd);
    } catch (e) {
      debugPrint('Failed to add item from suggestion: $e');
    }
    setState(() {
      _showSuggestions = false;
      _searchController.clear();
    });
    // After adding, refresh the list
    await _refreshListItems();
    if (widget.onItemsChanged != null) {
      widget.onItemsChanged!();
    }
  }

      void _onQuantityTap(Map<String, dynamic> item) async {
        // TODO: Show dialog to change quantity
      }

      void _onFavoriteTap(Map<String, dynamic> item) {
        // TODO: Mark as favorite
      }

      void _onPhotoTap(Map<String, dynamic> item) {
        // TODO: Add photo
      }

      void _onDeleteItem(Map<String, dynamic> item) {
        // TODO: Delete item
      }

      void _onCheckChanged(Map<String, dynamic> item, bool? checked) {
        setState(() {
          item['checked'] = checked == true;
        });
        if (widget.onItemsChanged != null) {
          widget.onItemsChanged!();
        }
      }

      Widget _buildItemCard(Map<String, dynamic> item, {bool checked = false}) {
        final theme = Theme.of(context);
        final emoji = item['emoji'] as String?;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.white,
            elevation: 0.5,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: (emoji != null && emoji.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    )
                  : null,
              title: Text(
                item['name']?.toString() ?? '',
                style: (item['checked'] == true)
                    ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
                    : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: item['qty'] != null
                  ? Text('Qty: ${item['qty']}', style: theme.textTheme.bodySmall)
                  : null,
              // Removed trailing arrow
              onTap: () async {
                final newChecked = !(item['checked'] == true);
                setState(() {
                  item['checked'] = newChecked;
                });
                try {
                  final api = ApiService();
                  await api.updateListItem(widget.list.id, item['id'], {'checked': newChecked});
                } catch (e) {
                  debugPrint('Failed to update item checked state: $e');
                  // Optionally show error to user
                }
                if (widget.onItemsChanged != null) {
                  widget.onItemsChanged!();
                }
              },
              onLongPress: () => _onQuantityTap(item),
            ),
          ),
        );
      }

      @override
      Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final loc = AppLocalizations.of(context)!;
  return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(widget.list.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      ),
                    ),
                    if (_showSuggestions)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _loadingSuggestions
                            ? const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                            : _suggestions.isEmpty
                                ? Text(AppLocalizations.of(context)!.noSuggestions)
                                : Column(
                                    children: [
                                      for (final s in _suggestions)
                                        ListTile(
                                          title: Text(s['name'] ?? ''),
                                          onTap: () => _onTapSuggestion(s),
                                        ),
                                    ],
                                  ),
                      ),
                  ],
                ),
              ),
              // Create New Item Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoriesPage(
                          accent: widget.accent,
                          listId: widget.list.id,
                        ),
                      ),
                    );
                    // Always refresh after returning from add item screen
                    await _refreshListItems();
                    if (widget.onItemsChanged != null) {
                      widget.onItemsChanged!();
                    }
                  },
                  child: CustomPaint(
                    painter: _DashedRRectPainter(
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
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline, size: 22, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Create New Item',
                            style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Grouped items by category
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    ...groupedUntickedItems.entries.expand((entry) => [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 0, 4),
                        child: Text(entry.key, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      ...entry.value.map((item) => _buildItemCard(item)),
                    ]),
                    if (checkedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 0, 4),
                        child: Text(AppLocalizations.of(context)!.completed, style: theme.textTheme.titleSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                      ...checkedItems.map((item) => _buildItemCard(item, checked: true)),
                    ],
                    if (untickedItems.isEmpty && checkedItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Center(
                          child: Text(loc.noItems, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: FooterMenu(accent: widget.accent),
        );
      }
    }
