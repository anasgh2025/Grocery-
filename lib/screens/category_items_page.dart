import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/add_item_details_sheet.dart';
import '../widgets/app_dialog.dart';

/// Full-screen page showing all items for a given grocery category.
/// Items are loaded from the backend API (MongoDB).
class CategoryItemsPage extends StatefulWidget {
  final String category;
  final IconData categoryIcon;
  final Color accent;
  final String listId;
  final String? initialCustomItemName;

  const CategoryItemsPage({
    Key? key,
    required this.category,
    required this.categoryIcon,
    required this.accent,
    required this.listId,
    this.initialCustomItemName,
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
    // If initialCustomItemName is provided, trigger _onItemTap automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCustomItemName != null && widget.initialCustomItemName!.isNotEmpty) {
        _onItemTap({'name': widget.initialCustomItemName!});
      }
    });
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
  final locale = Localizations.localeOf(context).languageCode;
  String name = (locale == 'ar' ? (item['name_ar'] ?? item['name']) : (item['name'] ?? '')) as String;
    Map<String, dynamic>? result;
    if (name.trim().toLowerCase() == 'other') {
      // Show dialog for free text entry
      final controller = TextEditingController();
      final customName = await showAppDialog<String>(
        context: context,
        title: const Text('Enter custom item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Item name'),
        ),
        actions: [
          appDialogCancelButton(onPressed: () => Navigator.of(context).pop()),
          appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), text: 'Add'),
        ],
      );
      if (customName == null || customName.isEmpty) return;
      name = customName;
    }
    result = await showAddItemDetailsSheet(
      // ignore: use_build_context_synchronously
      context,
      itemName: name,
      categoryLabel: widget.category,
      accent: widget.accent,
    );
    if (!mounted) return;
    if (result != null) {
      // Show full-screen loader while making the API call
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black38,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      try {
        final api = ApiService();
        // Fetch current items in the list
        final currentItems = await api.fetchListItems(widget.listId);
        if (!mounted) return;
        final resultName = result['name'] as String?;
        final resultQty = result['qty'] ?? 1;
        if (resultName == null) {
          Navigator.of(context).pop(); // dismiss loader
          return;
        }
        final existingIdx = currentItems.indexWhere(
          (it) => (it['name']?.toString().trim().toLowerCase() ?? '') == resultName.trim().toLowerCase(),
        );
        final existing = existingIdx != -1 ? currentItems[existingIdx] : null;
        if (existing != null) {
          final isAlreadyChecked = existing['checked'] == true;
          final currentQty = existing['qty'] is int
              ? existing['qty'] as int
              : int.tryParse(existing['qty']?.toString() ?? '') ?? 1;

          Navigator.of(context).pop(); // dismiss loader before showing dialog

          if (isAlreadyChecked) {
            // Item is checked — just inform the user, no increase option
            await showAppDialog<void>(
              context: context,
              title: const Text('Item already in list'),
              content: Text('"$resultName" is already in your list and has been checked off.'),
              actions: [
                appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(), text: 'OK'),
              ],
            );
          } else {
            // Item is active — offer to increase qty
            final shouldAddQty = await showAppDialog<bool>(
              context: context,
              title: const Text('Item already in list'),
              content: Text('"$resultName" is already in your list (qty: $currentQty). Would you like to increase the quantity?'),
              actions: [
                appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false), text: 'No'),
                const SizedBox(width: 12),
                appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Increase'),
              ],
            );
            if (!mounted) return;
            if (shouldAddQty == true) {
              final resolvedId = (existing['id'] ?? existing['_id'])?.toString() ?? '';
              if (resolvedId.isNotEmpty) {
                // Show loader again for the update call
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: Colors.black38,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
                await api.updateListItem(widget.listId, resolvedId, {'qty': currentQty + resultQty});
                if (mounted) {
                  Navigator.of(context).pop(); // dismiss loader
                  Navigator.of(context).pop(true); // go back
                }
              }
            }
          }
          return;
        } else {
          await api.addListItem(widget.listId, {
            'name': resultName,
            'qty': resultQty,
            'priority': result['priority'] ?? 0,
            // Use emoji from DB if available for this item name, else fallback
            'emoji': (() {
              final dbItem = _allItems.firstWhere(
                (it) => (it['name'] as String).trim().toLowerCase() == resultName.trim().toLowerCase(),
                orElse: () => <String, dynamic>{},
              );
              if (dbItem.containsKey('emoji') && (dbItem['emoji'] as String).isNotEmpty) {
                return dbItem['emoji'];
              }
              return '🛒';
            })(),
          });
          if (mounted) {
            Navigator.of(context).pop(); // dismiss loader
            Navigator.of(context).pop(true); // go back to list
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // dismiss loader on error
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
        backgroundColor: widget.accent,
        foregroundColor: Colors.white,
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
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.categoryIcon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              widget.category,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
                      final locale = Localizations.localeOf(context).languageCode;
                      final name = (locale == 'ar' ? (item['name_ar'] ?? item['name']) : (item['name'] ?? '')) as String;
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
