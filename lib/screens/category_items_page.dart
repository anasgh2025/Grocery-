import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/add_item_details_sheet.dart';

/// Full-screen page showing all items for a given grocery category.
/// Items are loaded from the backend API (MongoDB).
class CategoryItemsPage extends StatefulWidget {
  final String category;
  final IconData categoryIcon;
  final Color accent;
  final String listId;

  const CategoryItemsPage({
    Key? key,
    required this.category,
    required this.categoryIcon,
    required this.accent,
    required this.listId,
  }) : super(key: key);

  @override
  State<CategoryItemsPage> createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  final ApiService _api = ApiService();
  final String _search = '';
  // Removed unused _selectedPriorities field

  List<Map<String, dynamic>> _allItems = [];
  // ...existing code...

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final cat = await _api.fetchCategoryByLabel(widget.category);
      if (!mounted) return;
      debugPrint('[DEBUG] Category fetched: $cat');
      final rawItems = (cat['items'] as List<dynamic>?) ?? [];
      debugPrint('[DEBUG] Raw items: $rawItems');
      List<Map<String, dynamic>> parsedItems = [];
      try {
        parsedItems = rawItems.map((item) => Map<String, dynamic>.from(item)).toList();
        debugPrint('[DEBUG] Parsed items: $parsedItems');
      } catch (parseError) {
        debugPrint('[DEBUG] Error parsing items: $parseError');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing items: $parseError')),
        );
      }
      setState(() {
        _allItems = parsedItems;
      });
      debugPrint('[DEBUG] _allItems after setState: $_allItems');
    } catch (e) {
      debugPrint('[DEBUG] Error fetching category: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching category: $e')),
      );
      setState(() {
        // Optionally handle error, e.g., log or show a snackbar
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _allItems;
    return _allItems
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
    if (!mounted) return;
    if (result != null) {
      try {
        final api = ApiService();
        // Fetch current items in the list
        final currentItems = await api.fetchListItems(widget.listId);
        if (!mounted) return;
        final existing = currentItems.firstWhere(
          (it) => (it['name'] as String).trim().toLowerCase() == (result['name'] as String).trim().toLowerCase(),
          orElse: () => null,
        );
        if (existing != null) {
          // Show dialog to ask user if they want to add to quantity
          final shouldAddQty = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Item already exists'),
              content: Text('"${result['name']}" is already in your list. Add ${result['qty']} to the existing quantity?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Add Quantity'),
                ),
              ],
            ),
          );
          if (!mounted) return;
          if (shouldAddQty == true) {
            final newQty = (existing['qty'] ?? 1) + (result['qty'] ?? 1);
            await api.updateListItem(widget.listId, existing['id'], {
              ...existing,
              'qty': newQty,
            });
            if (mounted) Navigator.of(context).pop(true);
          }
          // If cancelled, do nothing
        } else {
          await api.addListItem(widget.listId, {
            'name': result['name'],
            'qty': result['qty'],
            'priority': result['priority'] ?? 0,
            // add other fields if needed
          });
          if (mounted) Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add item: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final items = _filtered;
  debugPrint('[DEBUG] items in build: $items');

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
                      final name = (item['name'] ?? '') as String;
                      final emoji = (item['emoji'] ?? '🛒') as String;
                      final priority = (item['priority'] ?? 0) as int;
                      return Stack(
                        children: [
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              leading: SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                              ),
                              title: Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                              subtitle: Text(widget.category, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                              onTap: () => _onItemTap(item),
                            ),
                          ),
                          if (priority == 1)
                            Positioned(
                              top: 8,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withAlpha(26),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.redAccent.withAlpha(80)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.priority_high, size: 14, color: Colors.redAccent),
                                    SizedBox(width: 4),
                                    Text('Urgent', style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
