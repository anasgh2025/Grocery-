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

  List<Map<String, dynamic>> _allItems = [];
  // ── Multi-select state ────────────────────────────────────────────────────
  final Set<String> _selectedNames = {};

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

  // ── Batch add all selected items ─────────────────────────────────────────
  Future<void> _addSelectedItems() async {
    if (_selectedNames.isEmpty) return;
    final names = List<String>.from(_selectedNames);

    // Show full-screen loader
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    int added = 0;
    int increased = 0;

    try {
      final api = ApiService();
      final currentItems = await api.fetchListItems(widget.listId);
      if (!mounted) return;

      for (final name in names) {
        final existingIdx = currentItems.indexWhere(
          (it) => (it['name']?.toString().trim().toLowerCase() ?? '') == name.trim().toLowerCase(),
        );
        if (existingIdx != -1) {
          final existing = currentItems[existingIdx];
          // Already checked → skip silently
          if (existing['checked'] == true) continue;
          // Active duplicate → silently increase qty by 1
          final resolvedId = (existing['id'] ?? existing['_id'])?.toString() ?? '';
          final currentQty = existing['qty'] is int
              ? existing['qty'] as int
              : int.tryParse(existing['qty']?.toString() ?? '') ?? 1;
          if (resolvedId.isNotEmpty) {
            await api.updateListItem(widget.listId, resolvedId, {'qty': currentQty + 1});
            increased++;
          }
        } else {
          // Find the item data for emoji
          final dbItem = _allItems.firstWhere(
            (it) => (it['name'] as String).trim().toLowerCase() == name.trim().toLowerCase(),
            orElse: () => <String, dynamic>{},
          );
          final emoji = (dbItem['emoji'] as String?) ?? '🛒';
          final priority = (dbItem['priority'] ?? 0) as int;
          await api.addListItem(widget.listId, {
            'name': name,
            'qty': 1,
            'priority': priority,
            'emoji': emoji,
          });
          added++;
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loader

      // Build result message
      final parts = <String>[];
      if (added > 0) parts.add('$added item${added > 1 ? 's' : ''} added');
      if (increased > 0) parts.add('$increased qty increased');
      final msg = parts.isNotEmpty ? parts.join(', ') : 'No new items added';

      Navigator.of(context).pop(true); // go back to list
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // dismiss loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add items: $e')),
        );
      }
    }
  }

  Future<void> _onItemTap(Map<String, dynamic> item) async {
  final locale = Localizations.localeOf(context).languageCode;
  String name = (locale == 'ar' ? (item['name_ar'] ?? item['name']) : (item['name'] ?? '')) as String;
    Map<String, dynamic>? result;
    if (name.trim().toLowerCase() == 'other') {
      // Show bottom sheet for free text entry
      final controller = TextEditingController();
      final customName = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              String? errorText;
              void trySubmit() {
                if (controller.text.trim().isEmpty) {
                  setSheetState(() => errorText = 'Item name is required');
                } else {
                  Navigator.of(ctx).pop(controller.text.trim());
                }
              }
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Drag handle ──
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // ── Title ──
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.accent.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.edit_rounded, color: widget.accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Enter custom item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // ── Text field ──
                      TextField(
                        controller: controller,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) {
                          if (errorText != null) setSheetState(() => errorText = null);
                        },
                        decoration: InputDecoration(
                          hintText: 'Item name',
                          errorText: errorText,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: errorText != null ? Colors.red : widget.accent, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        onSubmitted: (_) => trySubmit(),
                      ),
                      const SizedBox(height: 16),
                      // ── Buttons ──
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: widget.accent,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: trySubmit,
                              child: const Text('Add'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
          Expanded(
            child: Stack(
              children: [
                // ── Scrollable item list ──────────────────────────────
                items.isEmpty
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
                    // Top padding clears only the floating card
                    padding: const EdgeInsets.fromLTRB(16, 78, 16, 24),
                    itemCount: items.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      // ── Index 0: count label (scrolls with the list) ──
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            '${items.length} item${items.length == 1 ? '' : 's'}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                          ),
                        );
                      }
                      final item = items[i - 1];
                      final locale = Localizations.localeOf(context).languageCode;
                      final name = (locale == 'ar' ? (item['name_ar'] ?? item['name']) : (item['name'] ?? '')) as String;
                      final emoji = (item['emoji'] ?? '🛒') as String;
                      final priority = (item['priority'] ?? 0) as int;
                      final isSelected = _selectedNames.contains(name);
                      return Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected ? widget.accent.withAlpha(20) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? widget.accent : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedNames.remove(name);
                                    } else {
                                      _selectedNames.add(name);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      // ── Checkbox ──────────────────────
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: isSelected,
                                          activeColor: widget.accent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                          onChanged: (_) {
                                            setState(() {
                                              if (isSelected) {
                                                _selectedNames.remove(name);
                                              } else {
                                                _selectedNames.add(name);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // ── Emoji ─────────────────────────
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                                      ),
                                      const SizedBox(width: 10),
                                      // ── Name + category ───────────────
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                            Text(widget.category, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                                          ],
                                        ),
                                      ),
                                      // ── Urgent badge ──────────────────
                                      if (priority == 1)
                                        Container(
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                // ── Floating "Can't find item?" card ─────────────────
                Positioned(
                  left: 16,
                  right: 16,
                  top: 12,
                  child: GestureDetector(
                    onTap: () => _onItemTap({'name': 'other'}),
                    child: CustomPaint(
                      painter: _DashedBorderPainter(color: widget.accent),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(240),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accent.withAlpha(30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: widget.accent.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_rounded, color: widget.accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Can't find your item?",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: widget.accent,
                                    ),
                                  ),
                                  Text(
                                    'Tap here to add it manually',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: widget.accent.withAlpha(180),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: widget.accent.withAlpha(160)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          // ── Add to list CTA ─────────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _selectedNames.isEmpty
                ? const SizedBox.shrink()
                : SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.accent,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _addSelectedItems,
                        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
                        label: Text(
                          'Add ${_selectedNames.length} item${_selectedNames.length > 1 ? 's' : ''} to list',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Dashed border painter ─────────────────────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 14;
    const double dashWidth = 6;
    const double dashGap = 4;
    const double strokeWidth = 1.5;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
