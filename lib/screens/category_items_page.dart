import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/add_item_details_sheet.dart';

/// Full-screen page showing all items for a given grocery category.
/// Items are loaded from the backend API (MongoDB).
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
  final ApiService _api = ApiService();
  String _search = '';
  final Map<String, int> _selectedPriorities = {};

  List<Map<String, dynamic>> _allItems = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final cat = await _api.fetchCategoryByLabel(widget.category);
      final rawItems = (cat['items'] as List<dynamic>?) ?? [];
      setState(() {
        _allItems = rawItems.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
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
    if (result != null && mounted) {
      await widget.onItemAdded(result);
      if (mounted) Navigator.of(context).pop();
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Failed to load items.\n$_error',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red.shade400),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() { _loading = true; _error = null; });
                          _loadItems();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
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
                                final name = item['name'] as String;
                                final emoji = (item['emoji'] as String?) ?? '🛒';
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
