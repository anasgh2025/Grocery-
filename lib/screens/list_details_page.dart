// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
// import '../l10n/app_localizations.dart'; // Removed unused import
// import 'categories_page.dart'; // Removed unused import
import '../services/api_service.dart';
import '../widgets/app_dialog.dart';

import '../widgets/add_item_details_sheet.dart';
import 'categories_page.dart';



class ListDetailsPage extends StatefulWidget {
  final dynamic list;
  final Color accent;
  final Function? onItemsChanged;
  const ListDetailsPage({Key? key, required this.list, required this.accent, this.onItemsChanged}) : super(key: key);

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
  

}


class _ListDetailsPageState extends State<ListDetailsPage> {
  String _searchQuery = '';
  List<dynamic> _listItems = [];
  bool _isLoading = false;
  bool _showComingSoon = false; // controls the "Coming Soon" label visibility

  // ── Global search / suggestions ──────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;   // true while the HTTP call is in flight

  String get _resolvedListId {
    if (widget.list is Map) {
      return (widget.list['id'] ?? '').toString();
    }
    return (widget.list?.id ?? '').toString();
  }


  @override
  void initState() {
    super.initState();
    // Optionally show cached items immediately
    if (widget.list is Map) {
      _listItems = List<dynamic>.from(widget.list['listItems'] as List<dynamic>? ?? []);
    } else {
      _listItems = List<dynamic>.from(widget.list.listItems as List<dynamic>? ?? []);
    }
    // Always fetch latest from backend
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshListItems());
  }

  @override
  Widget build(BuildContext context) {
    final allFiltered = _searchQuery.isEmpty
        ? List<dynamic>.from(_listItems)
        : _listItems.where((item) =>
            (item['name']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase())
          ).toList();
    // Unchecked items first, checked at the bottom
    final filteredItems = [
      ...allFiltered.where((item) => item['checked'] != true),
      ...allFiltered.where((item) => item['checked'] == true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list is Map
            ? (widget.list['name']?.toString() ?? 'List')
            : (widget.list.name?.toString() ?? 'List')),
        backgroundColor: widget.accent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Search or add items...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: widget.accent, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _suggestions = [];
                                });
                              },
                            )
                          : null,
                    ),
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    onChanged: (value) async {
                      setState(() {
                        _searchQuery = value;
                        if (value.length < 3) _suggestions = [];
                      });
                      if (value.length >= 3) {
                        setState(() => _isSearching = true);
                        try {
                          final api = ApiService();
                          final results = await api.searchItemSuggestions(value);
                          if (mounted && _searchController.text == value) {
                            setState(() {
                              _suggestions = results;
                              _isSearching = false;
                            });
                          }
                        } catch (_) {
                          if (mounted) setState(() => _isSearching = false);
                        }
                      }
                    },
                    onSubmitted: (value) async {
                      // Keyboard "Done" pressed
                      final trimmed = value.trim();
                      if (trimmed.isEmpty) return;
                      if (_suggestions.isNotEmpty) return; // user should pick from list
                      // No suggestions — ask to add as custom
                      final confirm = await showAppDialog<bool>(
                        context: context,
                        title: const Text('Item not found'),
                        content: Text('"$trimmed" was not found. Would you like to add it to your list?'),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false), text: 'No'),
                              const SizedBox(width: 12),
                              appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Add'),
                            ],
                          ),
                        ],
                      );
                      if (confirm == true) {
                        await _addItemByName(trimmed);
                      }
                    },
                  ),
                ),
                // ── Suggestions dropdown ──────────────────────────────────
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: LinearProgressIndicator(
                      color: widget.accent,
                      backgroundColor: widget.accent.withAlpha(30),
                    ),
                  ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, i) {
                          final s = _suggestions[i];
                          final emoji = s['emoji']?.toString() ?? '';
                          final sName = s['name']?.toString() ?? '';
                          return InkWell(
                            onTap: () => _addSuggestionItem(s),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  if (emoji.isNotEmpty)
                                    Text(emoji, style: const TextStyle(fontSize: 22)),
                                  if (emoji.isNotEmpty) const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      sName,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Icon(Icons.add_circle_outline, color: widget.accent, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshListItems,
              child: filteredItems.isEmpty
                  ? ListView(
                      children: const [Center(child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text('No items in this list.'),
                      ))],
                    )
                  : _buildSectionedList(filteredItems),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              heroTag: 'addItem',
              backgroundColor: widget.accent,
              onPressed: () async {
                // Navigate to categories page and refresh if item was added
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoriesPage(
                      accent: widget.accent,
                      listId: _resolvedListId,
                    ),
                  ),
                );
                await _refreshListItems();
                if (widget.onItemsChanged != null) widget.onItemsChanged!();
              },
              tooltip: 'Create New Item',
              child: const Icon(Icons.add, size: 28),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.centerRight,
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: FloatingActionButton(
                  heroTag: 'voice',
                  backgroundColor: widget.accent,
                  onPressed: () {
                    setState(() => _showComingSoon = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _showComingSoon = false);
                    });
                  },
                  tooltip: 'Voice Search/Add',
                  child: const Icon(Icons.mic),
                ),
              ),
              // "Coming Soon" label that pops up to the left of the FAB
              if (_showComingSoon)
                Positioned(
                  right: 64,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Search helpers ────────────────────────────────────────────────────────

  /// Called when user taps a suggestion from the dropdown.
  Future<void> _addSuggestionItem(Map<String, dynamic> suggestion) async {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() { _searchQuery = ''; _suggestions = []; });

    final suggestedName = suggestion['name']?.toString() ?? '';

    // ── Duplicate check ──────────────────────────────────────────────────
    final dupIdx = _listItems.indexWhere(
      (it) => (it['name']?.toString().trim().toLowerCase() ?? '') ==
               suggestedName.trim().toLowerCase(),
    );
    if (dupIdx != -1) {
      final existing = _listItems[dupIdx] as Map<String, dynamic>;
      final isAlreadyChecked = existing['checked'] == true;
      final currentQty = existing['qty'] is int
          ? existing['qty'] as int
          : int.tryParse(existing['qty']?.toString() ?? '') ?? 1;

      if (isAlreadyChecked) {
        // Item is checked — just inform the user, no increase option
        await showAppDialog<void>(
          context: context,
          title: const Text('Item already in list'),
          content: Text('"$suggestedName" is already in your list and has been checked off.'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(), text: 'OK'),
              ],
            ),
          ],
        );
      } else {
        // Item is active — offer to increase qty
        final confirm = await showAppDialog<bool>(
          context: context,
          title: const Text('Item already in list'),
          content: Text('"$suggestedName" is already in your list (qty: $currentQty). Would you like to increase the quantity?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false), text: 'No'),
                const SizedBox(width: 12),
                appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Increase'),
              ],
            ),
          ],
        );
        if (confirm == true) {
          final resolvedId = (existing['id'] ?? existing['_id'])?.toString() ?? '';
          if (resolvedId.isNotEmpty) {
            try {
              final api = ApiService();
              await api.updateListItem(_resolvedListId, resolvedId, {'qty': currentQty + 1});
              await _refreshListItems();
              if (widget.onItemsChanged != null) widget.onItemsChanged!();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Increased "$suggestedName" quantity to ${currentQty + 1}.')),
              );
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update qty: $e')));
            }
          }
        }
      }
      return;
    }

    final details = await showAddItemDetailsSheet(
      context,
      itemName: suggestedName,
      categoryLabel: suggestion['category']?.toString() ?? '',
      accent: widget.accent,
    );
    if (details == null || !mounted) return;

    final itemToAdd = {
      'name': details['name'],
      'qty': details['qty'],
      'emoji': suggestion['emoji']?.toString().isNotEmpty == true
          ? suggestion['emoji']
          : '🛒',
      'priority': details['priority'] ?? 0,
      'checked': false,
    };
    try {
      final api = ApiService();
      await api.addListItem(_resolvedListId, itemToAdd);
      await _refreshListItems();
      if (widget.onItemsChanged != null) widget.onItemsChanged!();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "${details['name']}" to the list.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item: $e')),
        );
      }
    }
  }

  /// Called when user pressed Done on keyboard and no suggestions found.
  Future<void> _addItemByName(String name) async {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() { _searchQuery = ''; _suggestions = []; });

    // ── Duplicate check ──────────────────────────────────────────────────
    final dupIdx = _listItems.indexWhere(
      (it) => (it['name']?.toString().trim().toLowerCase() ?? '') ==
               name.trim().toLowerCase(),
    );
    if (dupIdx != -1) {
      final existing = _listItems[dupIdx] as Map<String, dynamic>;
      final isAlreadyChecked = existing['checked'] == true;
      final currentQty = existing['qty'] is int
          ? existing['qty'] as int
          : int.tryParse(existing['qty']?.toString() ?? '') ?? 1;

      if (isAlreadyChecked) {
        // Item is checked — just inform the user, no increase option
        await showAppDialog<void>(
          context: context,
          title: const Text('Item already in list'),
          content: Text('"$name" is already in your list and has been checked off.'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(), text: 'OK'),
              ],
            ),
          ],
        );
      } else {
        // Item is active — offer to increase qty
        final confirm = await showAppDialog<bool>(
          context: context,
          title: const Text('Item already in list'),
          content: Text('"$name" is already in your list (qty: $currentQty). Would you like to increase the quantity?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false), text: 'No'),
                const SizedBox(width: 12),
                appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Increase'),
              ],
            ),
          ],
        );
        if (confirm == true) {
          final resolvedId = (existing['id'] ?? existing['_id'])?.toString() ?? '';
          if (resolvedId.isNotEmpty) {
            try {
              final api = ApiService();
              await api.updateListItem(_resolvedListId, resolvedId, {'qty': currentQty + 1});
              await _refreshListItems();
              if (widget.onItemsChanged != null) widget.onItemsChanged!();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Increased "$name" quantity to ${currentQty + 1}.')),
              );
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update qty: $e')));
            }
          }
        }
      }
      return;
    }

    final details = await showAddItemDetailsSheet(
      context,
      itemName: name,
      categoryLabel: '',
      accent: widget.accent,
    );
    if (details == null || !mounted) return;

    final itemToAdd = {
      'name': details['name'],
      'qty': details['qty'],
      'emoji': '🛒',
      'priority': details['priority'] ?? 0,
      'checked': false,
    };
    try {
      final api = ApiService();
      await api.addListItem(_resolvedListId, itemToAdd);
      await _refreshListItems();
      if (widget.onItemsChanged != null) widget.onItemsChanged!();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "${details['name']}" to the list.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item: $e')),
        );
      }
    }
  }

  Future<void> _refreshListItems() async {
    final listId = _resolvedListId;
    debugPrint('[ListDetailsPage] _refreshListItems called, listId=$listId');
    if (listId.isEmpty) {
      debugPrint('[ListDetailsPage] listId is empty, cannot refresh');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final items = await api.fetchListItems(listId);
      debugPrint('[ListDetailsPage] Refreshed items count: ${items.length}');
      if (!mounted) return;
      setState(() {
        _listItems = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[ListDetailsPage] Failed to refresh list items: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load items: $e')),
        );
      }
    }
  }
  // ── Sectioned list ────────────────────────────────────────────────────────
  Widget _buildSectionedList(List<dynamic> filteredItems) {
    final active  = filteredItems.where((i) => i['checked'] != true).toList();
    final checked = filteredItems.where((i) => i['checked'] == true).toList();

    // Build a flat list of widgets: header + cards for each section
    final widgets = <Widget>[];

    if (active.isNotEmpty) {
      widgets.add(_buildSectionHeader('Active', widget.accent));
      for (final item in active) {
        widgets.add(_buildItemCard(item as Map<String, dynamic>));
      }
    }

    if (checked.isNotEmpty) {
      widgets.add(_buildSectionHeader('Checked', Colors.grey));
      for (final item in checked) {
        widgets.add(_buildItemCard(item as Map<String, dynamic>));
      }
    }

    return ListView(children: widgets);
  }

  Widget _buildSectionHeader(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showItemOptionsModal(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              if (item['emoji'] != null && item['emoji'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(item['emoji'], style: const TextStyle(fontSize: 26)),
                ),
              Expanded(
                child: Text(
                  item['name']?.toString() ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: item['checked'] == true
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: item['checked'] == true ? Colors.grey : null,
                  ),
                ),
              ),
              if (item['qty'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item['checked'] == true
                        ? Colors.grey.withAlpha(30)
                        : widget.accent.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'x${item['qty']}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: item['checked'] == true ? Colors.grey : widget.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Item options modal ─────────────────────────────────────────────────────
  void _showItemOptionsModal(Map<String, dynamic> item) async {
    final isChecked = item['checked'] == true;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showViewItemDialog(item);
                },
              ),
              ListTile(
                leading: Icon(isChecked ? Icons.check_box_outline_blank : Icons.check_box),
                title: Text(isChecked ? 'Uncheck' : 'Check'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _toggleItemChecked(item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showViewItemDialog(Map<String, dynamic> item) {
    final initialQty = (item['qty'] is int)
        ? item['qty'] as int
        : int.tryParse(item['qty']?.toString() ?? '') ?? 1;
    final emoji = item['emoji']?.toString() ?? '';
    final name = item['name']?.toString() ?? '';
    final isChecked = item['checked'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int qty = initialQty;
        bool isDirty = false;
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Emoji
                  if (emoji.isNotEmpty)
                    Text(emoji, style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Quantity picker — disabled for checked items
                  Opacity(
                    opacity: isChecked ? 0.38 : 1.0,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      const Spacer(),
                      // Decrease button
                      Material(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: (!isChecked && qty > 1)
                              ? () {
                                  setSheetState(() {
                                    qty--;
                                    isDirty = qty != initialQty;
                                  });
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.remove,
                                size: 22,
                                color: (!isChecked && qty > 1) ? widget.accent : Colors.grey.shade400),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$qty',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: widget.accent,
                          ),
                        ),
                      ),
                      // Increase button
                      Material(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: !isChecked
                              ? () {
                                  setSheetState(() {
                                    qty++;
                                    isDirty = qty != initialQty;
                                  });
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.add, size: 22, color: widget.accent),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(height: 28),
                  // Done CTA — only visible when qty changed (unchecked items only)
                  if (!isChecked)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: isDirty
                        ? SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: widget.accent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      setSheetState(() => isSaving = true);
                                      try {
                                        final api = ApiService();
                                        await api.updateListItem(
                                          _resolvedListId,
                                          item['id'],
                                          {'qty': qty},
                                        );
                                        // Update local state immediately
                                        setState(() {
                                          item['qty'] = qty;
                                        });
                                        if (widget.onItemsChanged != null) {
                                          widget.onItemsChanged!();
                                        }
                                        if (mounted) Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Updated "$name" quantity to $qty.'),
                                          ),
                                        );
                                      } catch (e) {
                                        setSheetState(() => isSaving = false);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to update quantity: $e')),
                                        );
                                      }
                                    },
                              child: isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(
                                      'Done',
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleItemChecked(Map<String, dynamic> item) async {
    final newChecked = !(item['checked'] == true);
    setState(() {
      item['checked'] = newChecked;
    });
    try {
      final api = ApiService();
      await api.updateListItem(
        _resolvedListId,
        item['id'],
        {
          'checked': newChecked,
          if (item['emoji'] != null) 'emoji': item['emoji'],
        },
      );
      if (widget.onItemsChanged != null) widget.onItemsChanged!();
    } catch (e) {
      debugPrint('Failed to update item checked state: $e');
    }
  }


}
