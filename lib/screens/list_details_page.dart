// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
// import '../l10n/app_localizations.dart'; // Removed unused import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/openai_service.dart';
// import 'categories_page.dart'; // Removed unused import
import '../services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
    // Initialize speech
    _speech = stt.SpeechToText();
    _initSpeech();
    // Always fetch latest from backend
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshListItems());
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _searchQuery.isEmpty
        ? _listItems
        : _listItems.where((item) =>
            (item['name']?.toString().toLowerCase() ?? '').contains(_searchQuery.toLowerCase())
          ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list is Map
            ? (widget.list['name']?.toString() ?? 'List')
            : (widget.list.name?.toString() ?? 'List')),
        backgroundColor: widget.accent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              height: 48,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: widget.accent,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                ),
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshListItems,
              child: filteredItems.isEmpty
                  ? ListView(
                      children: [Center(child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text('No items in this list.'),
                      ))],
                    )
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index] as Map<String, dynamic>;
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
                                        color: widget.accent.withAlpha(30),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'x${item['qty']}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: widget.accent,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
              child: const Icon(Icons.add, size: 28),
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
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              heroTag: 'voice',
              backgroundColor: widget.accent,
              child: const Icon(Icons.mic),
              onPressed: _startListening,
              tooltip: 'Voice Search/Add',
            ),
          ),
        ],
      ),
    );
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
  // Helper methods for item card actions (must be at the top for Dart forward reference)
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['name'] ?? ''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['emoji'] != null) Text('Emoji: ${item['emoji']}'),
            if (item['qty'] != null) Text('Quantity: ${item['qty']}'),
            if (item['category'] != null) Text('Category: ${item['category']}'),
            if (item['description'] != null) Text('Description: ${item['description']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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


  late stt.SpeechToText _speech;
  // bool _isListening = false; // Removed unused field
  String _voiceInput = '';
  bool _speechAvailable = false;

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        // No-op: _isListening removed
      },
      onError: (error) {
        // No-op: _isListening removed
      },
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_speechAvailable) {
      await _initSpeech();
    }
    if (_speechAvailable) {
      setState(() {
        _voiceInput = '';
      });
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _voiceInput = result.recognizedWords;
          });
          if (result.finalResult) {
            _processVoiceInput(_voiceInput);
            _speech.stop();
            // _isListening removed
          }
        },
        listenFor: const Duration(seconds: 6),
        pauseFor: const Duration(seconds: 2),
        localeId: 'en_US',
        cancelOnError: true,
        partialResults: true,
      );
    }
  }


  Future<void> _processVoiceInput(String input) async {
  // Use OpenAI to extract product and qty
    final openaiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    debugPrint('[VOICE] OpenAI API Key loaded: [32m${openaiApiKey.isNotEmpty}[0m');
    if (openaiApiKey.isEmpty) {
      debugPrint('[VOICE][ERROR] OpenAI API key not set.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OpenAI API key not set.')),
      );
      return;
    }
    final openai = OpenAIService(openaiApiKey);
    Map<String, dynamic>? aiResult;
    try {
      debugPrint('[VOICE] Sending to OpenAI: "$input"');
      aiResult = await openai.extractProductAndQty(input);
      debugPrint('[VOICE] OpenAI result: $aiResult');
    } catch (e, stack) {
      debugPrint('[VOICE][ERROR] Exception during OpenAI call: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OpenAI error: $e')),
      );
      return;
    }
    if (aiResult == null || aiResult['product'] == null || (aiResult['product'] as String).isEmpty) {
      debugPrint('[VOICE][ERROR] Could not understand item name from voice. aiResult: $aiResult');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not understand item name from voice.')),
      );
      return;
    }
    final name = aiResult['product'].toString();
    final qty = aiResult['qty'] is int ? aiResult['qty'] : int.tryParse(aiResult['qty']?.toString() ?? '1') ?? 1;
    try {
      final api = ApiService();
      debugPrint('[VOICE] Searching item suggestions for "$name"');
      final suggestions = await api.searchItemSuggestions(name);
      debugPrint('[VOICE] Suggestions: $suggestions');
      // Check if item already exists in the list
      final currentItems = _listItems; // use local state, always up to date
      final _existingIdx = currentItems.indexWhere(
        (it) => (it['name']?.toString().trim().toLowerCase() ?? '') == name.trim().toLowerCase(),
      );
      final existingItem = _existingIdx != -1 ? currentItems[_existingIdx] : null;
      if (existingItem != null) {
        // Ask user to confirm increasing quantity only
        final confirm = await showAppDialog<bool>(
          context: context,
          title: const Text('Item already exists'),
          content: Text('"$name" is already in your list. Add $qty to the existing quantity?'),
          actions: [
            appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false)),
            appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Add Quantity', color: Colors.red),
          ],
        );
        if (confirm == true) {
          final newQty = (existingItem['qty'] ?? 1) + qty;
          await api.updateListItem(_resolvedListId, existingItem['id'], {'qty': newQty});
          await _refreshListItems();
          if (widget.onItemsChanged != null) widget.onItemsChanged!();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Increased quantity of "$name" by $qty.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No item added.')),
          );
        }
      } else if (suggestions.isNotEmpty) {
        // Show dialog to let user confirm adding the best suggestion
        final selected = suggestions.first;
        final confirm = await showAppDialog<bool>(
          context: context,
          title: const Text('Did you mean:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(selected['name'] ?? ''),
              if (selected['category'] != null) Text(selected['category']),
              const SizedBox(height: 16),
              Text('Quantity: $qty'),
            ],
          ),
          actions: [
            appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false)),
            appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Confirm'),
          ],
        );
        if (confirm == true) {
          final itemToAdd = Map<String, dynamic>.from(selected);
          itemToAdd['qty'] = qty;
          if (itemToAdd['emoji'] == null || (itemToAdd['emoji'] as String).isEmpty) {
            itemToAdd['emoji'] = '🛒';
          }
          await api.addListItem(_resolvedListId, itemToAdd);
          await _refreshListItems();
          if (widget.onItemsChanged != null) widget.onItemsChanged!();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added "${itemToAdd['name']}" (Qty: $qty) from voice input.')),
          );
        } else {
          debugPrint('[VOICE] User cancelled suggestion dialog.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No item added.')),
          );
        }
      } else {
        debugPrint('[VOICE] No suggestions found for "$name". Asking user to confirm adding as custom item.');
        final confirm = await showAppDialog<bool>(
          context: context,
          title: const Text('Item not found'),
          content: Text('"$name" (Qty: $qty) is not in the list. Would you like to add it as a custom item?'),
          actions: [
            appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false), text: 'No'),
            appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Yes'),
          ],
        );
        if (confirm == true) {
          // Show add item details sheet for qty and photo
          final details = await showAddItemDetailsSheet(
            context,
            itemName: name,
            categoryLabel: '',
            accent: widget.accent,
          );
          if (details != null) {
            final itemToAdd = {
              'name': details['name'],
              'qty': details['qty'],
              'emoji': '🛒',
              if (details['photoPath'] != null) 'photoPath': details['photoPath'],
              'priority': details['priority'] ?? 0,
              'checked': false,
            };
            await api.addListItem(_resolvedListId, itemToAdd);
            await _refreshListItems();
            if (widget.onItemsChanged != null) widget.onItemsChanged!();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added "${details['name']}" (Qty: ${details['qty']}) as a custom item.')),
            );
          } else {
            debugPrint('[VOICE] User cancelled add item details sheet.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No item added.')),
            );
          }
        } else {
          debugPrint('[VOICE] User cancelled adding custom item.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No item added.')),
          );
        }
      }
    } catch (e, stack) {
      debugPrint('[VOICE][ERROR] Exception during item add: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item from voice: $e')),
      );
    }
  }


}