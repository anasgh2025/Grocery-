import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/grocery_list.dart';
import '../services/api_service.dart';
import '../widgets/box_styles.dart';
import 'category_items_page.dart';

class ListDetailsPage extends StatefulWidget {
  final GroceryList list;
  final Color accent;
  final VoidCallback? onItemsChanged;
  final VoidCallback? onListDeleted;

  const ListDetailsPage({Key? key, required this.list, required this.accent, this.onItemsChanged, this.onListDeleted}) : super(key: key);

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
}

class _ListDetailsPageState extends State<ListDetailsPage> {
  final TextEditingController _addItemController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  final ApiService _api = ApiService();
  final int _selectedPriority = 0; // 0 = Normal, 1 = Urgent

  /// Categories loaded from the backend API
  List<Map<String, dynamic>> _categories = [];
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load items from backend for this list
    _loadItems();
    _loadCategories();
  }

  Widget _buildPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return const Icon(Icons.priority_high, size: 18, color: Colors.redAccent);
      case 0:
      default:
        return const Icon(Icons.label_outline, size: 16, color: Colors.grey);
    }
  }

  Future<void> _loadItems() async {
    try {
      final items = await _api.fetchListItems(widget.list.id);
      setState(() {
        _items = List<Map<String, dynamic>>.from(items);
      });
    } catch (e) {
      // Log the error so we can see why fetching failed, then fallback to placeholder items
      // Also show a SnackBar to inform the user that items couldn't be loaded
      // ignore: avoid_print
      print('Error loading list items for ${widget.list.id}: $e');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load items for "${widget.list.name}": $e')),
          );
        }
      });
      setState(() {
        _items = List.generate(8, (i) => { 'id': 'p$i', 'name': 'Item ${i + 1}', 'qty': 1, 'checked': false });
      });
    }
  }

  /// Load categories from backend API
  Future<void> _loadCategories() async {
    try {
      final cats = await _api.fetchCategories();
      setState(() {
        _categories = cats.map((c) => {
          'label': c['label'] as String,
          'icon': _iconFromString(c['icon'] as String? ?? 'shopping_bag'),
        }).toList();
        _categoriesLoaded = true;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading categories: $e');
      // If loading fails, we leave _categories empty – the sheet will show a message
      setState(() => _categoriesLoaded = true);
    }
  }

  /// Map an icon name string (stored in DB) to Flutter IconData
  static IconData _iconFromString(String name) {
    switch (name) {
      case 'apple':              return Icons.apple;
      case 'eco':                return Icons.eco;
      case 'set_meal':           return Icons.set_meal;
      case 'water':              return Icons.water;
      case 'egg_alt':            return Icons.egg_alt;
      case 'bakery_dining':      return Icons.bakery_dining;
      case 'local_drink':        return Icons.local_drink;
      case 'cookie':             return Icons.cookie;
      case 'ac_unit':            return Icons.ac_unit;
      case 'grain':              return Icons.grain;
      case 'blender':            return Icons.blender;
      case 'inventory_2':        return Icons.inventory_2;
      case 'spa':                return Icons.spa;
      case 'opacity':            return Icons.opacity;
      case 'cake':               return Icons.cake;
      case 'child_care':         return Icons.child_care;
      case 'health_and_safety':  return Icons.health_and_safety;
      case 'cleaning_services':  return Icons.cleaning_services;
      case 'face':               return Icons.face;
      case 'pets':               return Icons.pets;
      case 'free_breakfast':     return Icons.free_breakfast;
      case 'rice_bowl':          return Icons.rice_bowl;
      case 'lunch_dining':       return Icons.lunch_dining;
      case 'shopping_bag':       return Icons.shopping_bag;
      default:                   return Icons.shopping_bag;
    }
  }

  Future<void> _addItem() async {
    final text = _addItemController.text.trim();
    if (text.isEmpty) return;
    final int priority = _selectedPriority;

    try {
      final created = await _api.addListItem(widget.list.id, {'name': text, 'qty': 1, 'priority': priority});
      setState(() {
        _items.add(created);
        _addItemController.clear();
      });
      // Notify parent that items changed so UI (list cards) can refresh if needed
      widget.onItemsChanged?.call();
    } catch (e) {
      // show snackbar on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add item: $e')));
      }
    }
  }

  /// Add an item from the category flow (includes qty, description, photoPath).
  Future<void> _addItemFromData(Map<String, dynamic> data) async {
    try {
      // If priority wasn't included in the data, use the selected priority from the add sheet
      int priority = data['priority'] ?? _selectedPriority;
      final name = (data['name'] as String? ?? '').trim();
      final addQty = (data['qty'] as int?) ?? 1;

      // If item already exists in the list, ask the user whether to increase the quantity
      final existingIdx = _items.indexWhere((i) => (i['name'] as String? ?? '').toLowerCase().trim() == name.toLowerCase());
      if (existingIdx != -1) {
        final existing = _items[existingIdx];
        final existingQty = (existing['qty'] as int?) ?? 1;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('Item already in list'),
            content: Text('"$name" already exists with quantity $existingQty. Increase by $addQty?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: widget.accent),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Increase'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          try {
            final updated = await _api.updateListItem(widget.list.id, existing['id'], {'qty': existingQty + addQty});
            setState(() {
              _items[existingIdx] = updated;
            });
            widget.onItemsChanged?.call();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Increased "$name" quantity to ${existingQty + addQty}'), backgroundColor: widget.accent, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
              );
            }
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update item quantity: $e')));
          }
        }

        return;
      }

      final payload = {
        'name': name,
        'qty': addQty,
        if ((data['description'] as String?)?.isNotEmpty == true)
          'description': data['description'],
        if (data['photoPath'] != null) 'photoPath': data['photoPath'],
        'checked': false,
        'priority': priority,
      };

      final created = await _api.addListItem(widget.list.id, payload);
      setState(() => _items.add(created));
      widget.onItemsChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name added to list'),
            backgroundColor: widget.accent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item: $e')),
        );
      }
    }
  }

  

  Future<void> _toggleChecked(Map<String, dynamic> item) async {
    try {
      final updated = await _api.updateListItem(widget.list.id, item['id'], {'checked': !item['checked']});
      setState(() {
        final idx = _items.indexWhere((i) => i['id'] == updated['id']);
        if (idx != -1) _items[idx] = updated;
      });
      widget.onItemsChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update item: $e')));
      }
    }
  }

  Future<void> _removeItem(Map<String, dynamic> item) async {
    try {
      await _api.deleteListItem(widget.list.id, item['id']);
      setState(() {
        _items.removeWhere((i) => i['id'] == item['id']);
      });
      widget.onItemsChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete item: $e')));
      }
    }
  }

  Future<void> _shareList() async {
    final buffer = StringBuffer('Here is the list of items for ${widget.list.name}:\n');
    for (var i = 0; i < _items.length; i++) {
      final name = _items[i]['name'] ?? 'Item ${i + 1}';
      buffer.write('${i + 1}. $name\n');
    }
    if (_items.isEmpty) {
      buffer.write('(No items yet)\n');
    }
    try {
      final box = context.findRenderObject() as RenderBox;
      final origin = box.localToGlobal(Offset.zero) & box.size;
      await Share.share(buffer.toString(), subject: widget.list.name, sharePositionOrigin: origin);
    } catch (_) {
      await Share.share(buffer.toString(), subject: widget.list.name);
    }
  }

  Future<void> _confirmDeleteList() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Delete list'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${widget.list.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _api.deleteGroceryList(widget.list.id);
      widget.onListDeleted?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete list: $e')),
        );
      }
    }
  }

  Future<void> _showAddDialog() async {
    _addItemController.clear();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: const [0.75, 0.95],
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Drag handle ──────────────────────────────────
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Title ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Add new item',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Top 25%: 3 action buttons ────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _ActionButton(
                          icon: Icons.search_rounded,
                          label: 'Search',
                          color: widget.accent,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _showSearchDialog();
                          },
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan',
                          color: widget.accent,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Barcode scanner coming soon')),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.mic_rounded,
                          label: 'Voice',
                          color: widget.accent,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Voice input coming soon')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Priority removed from create sheet — selection is handled in category flow

                  // ── Divider ──────────────────────────────────────
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 12),

                  // ── Category label ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Browse by category',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Bottom 50%: scrollable category list ─────────
                  Expanded(
                    child: !_categoriesLoaded
                        ? const Center(child: CircularProgressIndicator())
                        : _categories.isEmpty
                            ? Center(
                                child: Text(
                                  'No categories available',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CategoryItemsPage(
                                  category: cat['label'] as String,
                                  categoryIcon: cat['icon'] as IconData,
                                  accent: widget.accent,
                                  onItemAdded: _addItemFromData,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                // Avoid deprecated withOpacity; use withAlpha for low-opacity shadow
                                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 6, offset: const Offset(0, 1)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: widget.accent.withAlpha(38),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(cat['icon'] as IconData, size: 22, color: widget.accent),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    cat['label'] as String,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(sheetContext).viewInsets.bottom + 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  

  Future<void> _showSearchDialog({String prefill = ''}) async {
    _addItemController.text = prefill;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.search_rounded, color: widget.accent),
              const SizedBox(width: 8),
              const Text('Search item'),
            ],
          ),
          content: TextField(
            controller: _addItemController,
            decoration: InputDecoration(
              hintText: 'e.g. Apples, Milk…',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.search),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) async {
              Navigator.of(ctx).pop();
              await _addItem();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: widget.accent),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _addItem();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'delete') _confirmDeleteList();
              if (value == 'share') _shareList();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, color: Colors.black87, size: 20),
                    SizedBox(width: 10),
                    Text('Share list'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 10),
                    Text('Delete list', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number of items
            Row(
              children: [
                        Icon(widget.list.icon, color: widget.accent, size: 24),
                const SizedBox(width: 8),
                Text('${_items.length} items', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            // Grid of item cards (3 columns x 4 rows visible)
            Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    // Use same aspect ratio as list cards so heights match
                    childAspectRatio: 1.05,
                  ),
                itemCount: _items.length + 1,
                itemBuilder: (context, index) {
                  // First card is the "Add new item" card, remaining are existing items
                  if (index == 0) {
                    // Match the "Create New List" card's typography and sizing
                    return InkWell(
                      onTap: _showAddDialog,
                            child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 1.6),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: 24, color: Colors.grey),
                            SizedBox(height: 3),
                            Text(
                              'Add\nItem',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final item = _items[index - 1];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _toggleChecked(item),
                    onLongPress: () async {
                      // Confirm delete on long-press to avoid accidental removals
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: const Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete item'),
                            ],
                          ),
                          content: Text('Are you sure you want to delete "${item['name']}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await _removeItem(item);
                      }
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: appBoxDecoration(
                        context,
                        color: item['checked'] == true ? const Color(0xFF1A237E).withAlpha(40) : Colors.white,
                        radius: 12,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: leading icon (top-left) and qty (top-right)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: widget.accent.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.inventory_2, size: 20, color: Colors.black54),
                              ),
                              const Spacer(),
                              Text(
                                'Qty: \\${item['qty'] ?? 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Title in the middle
                          Expanded(
                            child: Text(
                              item['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Bottom row: check icon or priority icon aligned to bottom-right
                          Row(
                            children: [
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: item['checked'] == true
                                    ? const Icon(Icons.check_circle, size: 20, color: Colors.green)
                                    : _buildPriorityIcon(item['priority'] ?? 0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  }

// ─── Reusable action button widget for the bottom sheet ───────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
            child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(64)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  