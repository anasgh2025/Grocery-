// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'category_items_page.dart';

class CategoriesPage extends StatefulWidget {
  final Color accent;
  final String listId;
  const CategoriesPage({Key? key, required this.accent, required this.listId}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _categories = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final cats = await _api.fetchCategories(lang: lang);
      setState(() {
        _categories = cats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.categories, style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: widget.accent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
              ? Center(child: Text('${loc.failedToLoadCategories}\n$_error', textAlign: TextAlign.center))
        : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _categories.length,
          itemBuilder: (context, i) {
                    final cat = _categories[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Material(
                        color: Colors.white,
                        elevation: 0.5,
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: Icon(_iconForCategory(cat['icon']), color: widget.accent, size: 32),
                          title: Text(
                            cat['label'] ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: (cat['itemCount'] != null)
                              ? Text('${cat['itemCount']} ${loc.items}', style: theme.textTheme.bodySmall)
                              : null,
                          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () async {
                            final categoryLabel = cat['label'] ?? '';
                            if (categoryLabel.trim().toLowerCase() == 'other') {
                              // Show dialog for free text entry
                              final controller = TextEditingController();
                              final customName = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(loc.enterCustomItem),
                                  content: TextField(
                                    controller: controller,
                                    autofocus: true,
                                    decoration: InputDecoration(hintText: loc.itemName),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: Text(loc.cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                                      child: Text(loc.add),
                                    ),
                                  ],
                                ),
                              );
                              if (customName == null || customName.isEmpty) return;
                              // Call _onItemTap in CategoryItemsPage logic for duplicate/quantity dialog
                              // We need to push CategoryItemsPage and trigger _onItemTap with the custom item
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CategoryItemsPage(
                                    category: categoryLabel,
                                    categoryIcon: _iconForCategory(cat['icon']),
                                    accent: widget.accent,
                                    listId: widget.listId,
                                    initialCustomItemName: customName,
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              if (result == true) {
                                Navigator.of(context).pop(true);
                              }
                              // To trigger _onItemTap, you may need to add logic in CategoryItemsPage to check for an initial custom item and call _onItemTap automatically.
                            } else {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CategoryItemsPage(
                                    category: categoryLabel,
                                    categoryIcon: _iconForCategory(cat['icon']),
                                    accent: widget.accent,
                                    listId: widget.listId,
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              if (result == true) {
                                Navigator.of(context).pop(true);
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
// ...existing code...

  IconData _iconForCategory(String? iconName) {
    switch (iconName) {
      case 'apple':
        return Icons.apple;
      case 'eco':
        return Icons.eco;
      case 'set_meal':
        return Icons.set_meal;
      case 'water':
        return Icons.water;
      case 'egg_alt':
        return Icons.egg_alt;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'local_drink':
        return Icons.local_drink;
      case 'shopping_bag':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}
