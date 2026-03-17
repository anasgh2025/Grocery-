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
        title: Text(loc.categories, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: widget.accent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
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
                                          setSheetState(() => errorText = loc.itemName + ' is required');
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
                                                    loc.enterCustomItem,
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
                                                  hintText: loc.itemName,
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
                                                      child: Text(loc.cancel),
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
                                                      child: Text(loc.add),
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
