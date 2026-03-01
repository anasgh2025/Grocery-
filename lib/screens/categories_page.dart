import 'package:flutter/material.dart';
import '../services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await _api.fetchCategories();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: widget.accent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
              ? Center(child: Text('Failed to load categories.\n$_error', textAlign: TextAlign.center))
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
                              ? Text('${cat['itemCount']} items', style: theme.textTheme.bodySmall)
                              : null,
                          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CategoryItemsPage(
                                  category: cat['label'] ?? '',
                                  categoryIcon: _iconForCategory(cat['icon']),
                                  accent: widget.accent,
                                  listId: widget.listId,
                                ),
                              ),
                            );
                            if (result == true) {
                              Navigator.of(context).pop(true);
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
