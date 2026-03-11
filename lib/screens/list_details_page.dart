// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/footer_menu.dart';
import 'categories_page.dart';
import '../services/api_service.dart';
import '../services/openai_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/app_dialog.dart';

// Dashed border painter for the 'Create New Item' card
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = (distance + dashWidth).clamp(0.0, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;


  }


class ListDetailsPage extends StatefulWidget {
  final dynamic list;
  final Color accent;
  final Function? onItemsChanged;
  const ListDetailsPage({Key? key, required this.list, required this.accent, this.onItemsChanged}) : super(key: key);

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
  

}

class _ListDetailsPageState extends State<ListDetailsPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = '';
  bool _speechAvailable = false;
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
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
        _isListening = true;
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
            setState(() => _isListening = false);
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

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
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
      final existingItem = widget.list.listItems.firstWhere(
        (item) => (item['name']?.toString().trim().toLowerCase() ?? '') == name.trim().toLowerCase(),
        orElse: () => null,
      );
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
          await api.updateListItem(widget.list.id, existingItem['id'], {'qty': newQty});
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
          await api.addListItem(widget.list.id, itemToAdd);
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
          final itemToAdd = {
            'name': name,
            'qty': qty,
            'emoji': '🛒',
          };
          await api.addListItem(widget.list.id, itemToAdd);
          await _refreshListItems();
          if (widget.onItemsChanged != null) widget.onItemsChanged!();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added "$name" (Qty: $qty) as a custom item.')),
          );
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
      Widget _buildListTile(Map<String, dynamic> item, ThemeData theme, String? emoji) {
        // Debug prints for crash diagnosis
        debugPrint('Building ListTile for item: $item');
        debugPrint('widget.list: [33m${widget.list}[0m');
        debugPrint('widget.list.id: [33m${widget.list != null && widget.list is Map && widget.list["id"] != null ? widget.list["id"] : widget.list?.id}[0m');
        debugPrint('item["id"]: [33m${item['id']}[0m');
        if (widget.list == null) {
          debugPrint('ERROR: widget.list is null');
          return const ListTile(title: Text('Error: List is null'));
        }
        final listId = widget.list is Map ? widget.list['id'] : widget.list.id;
        if (listId == null) {
          debugPrint('ERROR: widget.list.id is null');
          return const ListTile(title: Text('Error: List ID is null'));
        }
        if (item['id'] == null) {
          debugPrint('ERROR: item["id"] is null');
          return const ListTile(title: Text('Error: Item ID is null'));
        }
        return Material(
          color: Colors.white,
          elevation: 0.5,
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            leading: (emoji != null && emoji.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  )
                : null,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item['name']?.toString() ?? '',
                    style: (item['checked'] == true)
                        ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
                        : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item['qty'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      onTap: (item['checked'] == true) ? null : () => _onQuantityTap(item),
                      child: Text(
                        'Qty: ${item['qty']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (item['checked'] == true)
                              ? Colors.grey
                              : theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () async {
              final newChecked = !(item['checked'] == true);
              bool mounted = true;
              try {
                setState(() {
                  item['checked'] = newChecked;
                });
              } catch (e) {
                debugPrint('setState error: $e');
                mounted = false;
              }
              try {
                final api = ApiService();
                await api.updateListItem(
                  listId,
                  item['id'],
                  {
                    'checked': newChecked,
                    if (item['emoji'] != null) 'emoji': item['emoji'],
                  },
                );
              } catch (e) {
                debugPrint('Failed to update item checked state: $e');
              }
              if (mounted && widget.onItemsChanged != null) {
                try {
                  widget.onItemsChanged!();
                } catch (e) {
                  debugPrint('onItemsChanged error: $e');
                }
              }
            },
          ),
        );
      }

  Future<void> _refreshListItems() async {
    try {
      final api = ApiService();
      final items = await api.fetchListItems(widget.list.id);
      setState(() {
        widget.list.listItems = items;
      });
    } catch (e) {
      // Optionally show error
      debugPrint('Failed to refresh items: $e');
    }
  }
  final TextEditingController _searchController = TextEditingController();
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _suggestions = [];
  bool _loadingSuggestions = false;

  List<Map<String, dynamic>> get untickedItems {
    final items = widget.list.listItems;
    if (items == null) return [];
    return List<Map<String, dynamic>>.from(items.where((item) => item is Map && (item['checked'] != true)));
  }

  List<Map<String, dynamic>> get checkedItems {
    final items = widget.list.listItems;
    if (items == null) return [];
    return List<Map<String, dynamic>>.from(items.where((item) => item is Map && (item['checked'] == true)));
  }

  Map<String, List<Map<String, dynamic>>> get groupedUntickedItems {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in untickedItems) {
      final cat = (item['category'] is String && (item['category'] as String).isNotEmpty)
          ? item['category'] as String
          : 'Other';
      grouped.putIfAbsent(cat, () => []).add(item);
    }
    // Logical group order
    const logicalOrder = [
      'Fruit', 'Vegetable', 'Veg', 'Meat', 'Dairy', 'Bakery', 'Beverage', 'Pantry', 'Frozen', 'Snacks', 'Other'
    ];
    final keys = grouped.keys.toList();
    keys.sort((a, b) {
      final ia = logicalOrder.indexWhere((cat) => a.toLowerCase().contains(cat.toLowerCase()));
      final ib = logicalOrder.indexWhere((cat) => b.toLowerCase().contains(cat.toLowerCase()));
      if (ia == -1 && ib == -1) return a.compareTo(b); // both not found, fallback alpha
      if (ia == -1) return 1; // a not found, b found
      if (ib == -1) return -1; // b not found, a found
      return ia.compareTo(ib);
    });
    final Map<String, List<Map<String, dynamic>>> sortedGrouped = {};
    for (final k in keys) {
      sortedGrouped[k] = grouped[k]!;
    }
    return sortedGrouped;
  }

  void _onSearchChanged(String value) async {
    if (value.length < 3) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }
    setState(() {
      _showSuggestions = true;
      _loadingSuggestions = true;
    });
    try {
      final api = ApiService();
      final results = await api.searchItemSuggestions(value);
      setState(() {
        _suggestions = results;
        _loadingSuggestions = false;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _loadingSuggestions = false;
      });
      debugPrint('Failed to fetch suggestions: $e');
    }
  }

  void _onTapSuggestion(Map<String, dynamic> suggestion) async {
    final api = ApiService();
    final emoji = (suggestion['emoji'] is String && (suggestion['emoji'] as String).isNotEmpty)
        ? suggestion['emoji'] as String
        : '🛒';
    final itemName = (suggestion['name'] ?? '').toString().trim().toLowerCase();
    final existingItem = widget.list.listItems.firstWhere(
      (item) => (item['name']?.toString().trim().toLowerCase() ?? '') == itemName,
      orElse: () => null,
    );
    if (existingItem != null) {
      // Ask user to confirm increasing quantity only
      final result = await showAppDialog<bool>(
        context: context,
        title: const Text('Item already exists'),
        content: Text('"${existingItem['name']}" is already in your list. Add 1 to the existing quantity?'),
        actions: [
          appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false)),
          appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Add Quantity', color: Colors.red),
        ],
      );
      if (result == true) {
        final newQty = (existingItem['qty'] ?? 1) + 1;
        try {
          await api.updateListItem(widget.list.id, existingItem['id'], {'qty': newQty});
          setState(() {
            existingItem['qty'] = newQty;
            _showSuggestions = false;
            _searchController.clear();
          });
          if (widget.onItemsChanged != null) widget.onItemsChanged!();
        } catch (e) {
          debugPrint('Failed to update item qty: $e');
        }
      } else {
        setState(() {
          _showSuggestions = false;
          _searchController.clear();
        });
      }
      return;
    }
    // No duplicate, add as new item
    final itemToAdd = Map<String, dynamic>.from(suggestion);
    itemToAdd['emoji'] = emoji;
    try {
      await api.addListItem(widget.list.id, itemToAdd);
    } catch (e) {
      debugPrint('Failed to add item from suggestion: $e');
    }
    setState(() {
      _showSuggestions = false;
      _searchController.clear();
    });
    await _refreshListItems();
    if (widget.onItemsChanged != null) {
      widget.onItemsChanged!();
    }
  }

  Future<void> _onQuantityTap(Map<String, dynamic> item) async {
    final theme = Theme.of(context);
    int initialQty = item['qty'] ?? 1;
    int tempQty = initialQty;
    final result = await showAppDialog<int>(
      context: context,
      title: const Text('Change Quantity'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: tempQty > 1 ? () => setState(() { tempQty--; }) : null,
              ),
              Text('$tempQty', style: theme.textTheme.headlineSmall),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() { tempQty++; }),
              ),
            ],
          );
        },
      ),
      actions: [
        appDialogCancelButton(onPressed: () => Navigator.of(context).pop()),
        appDialogConfirmButton(
          onPressed: () {
            Navigator.of(context).pop(tempQty);
          },
          text: 'Done',
          color: Colors.red,
        ),
      ],
    );
    if (result != null && result != (item['qty'] ?? 1)) {
      setState(() {
        item['qty'] = result;
      });
      try {
        final api = ApiService();
        await api.updateListItem(widget.list.id, item['id'], {'qty': result});
      } catch (e) {
        debugPrint('Failed to update item qty: $e');
      }
      if (widget.onItemsChanged != null) {
        widget.onItemsChanged!();
      }
    }
  }

  Widget _buildItemCard(Map<String, dynamic> item, {bool checked = false}) {
    final theme = Theme.of(context);
    final emoji = item['emoji'] as String?;
    final tile = _buildListTile(item, theme, emoji);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: (item['checked'] == true)
          ? tile
          : Dismissible(
              key: ValueKey(item['id']),
              direction: DismissDirection.startToEnd,
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 24),
                color: Colors.redAccent,
                child: const Icon(Icons.delete, color: Colors.white, size: 28),
              ),
              confirmDismiss: (direction) async {
                return await showAppDialog<bool>(
                  context: context,
                  title: const Text('Delete Item'),
                  content: Text('Are you sure you want to delete "${item['name']}"?'),
                  actions: [
                    appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false)),
                    appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Delete', color: Colors.redAccent),
                  ],
                ) ?? false;
              },
              onDismissed: (direction) async {
                try {
                  final api = ApiService();
                  await api.deleteListItem(widget.list.id, item['id']);
                  setState(() {
                    widget.list.listItems.removeWhere((it) => it['id'] == item['id']);
                  });
                  if (widget.onItemsChanged != null) {
                    widget.onItemsChanged!();
                  }
                } catch (e) {
                  debugPrint('Failed to delete item: $e');
                }
              },
              child: tile,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(widget.list.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.black),
                onPressed: _isListening ? _stopListening : _startListening,
                tooltip: _isListening ? 'Stop Listening' : 'Voice Input',
              ),
          if (_isListening)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.hearing, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _voiceInput.isEmpty ? 'Listening...' : _voiceInput,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      ),
                    ),
                    if (_showSuggestions)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _loadingSuggestions
                            ? const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                            : _suggestions.isEmpty
                                ? Text(AppLocalizations.of(context)!.noSuggestions)
                                : Column(
                                    children: [
                                      for (final s in _suggestions)
                                        ListTile(
                                          title: Text(s['name'] ?? ''),
                                          onTap: () => _onTapSuggestion(s),
                                        ),
                                    ],
                                  ),
                      ),
                  ],
                ),
              ),
              // Create New Item Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: GestureDetector(
                  onTap: () async {
                    // Navigate to category selection and expect result with item info
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoriesPage(
                          accent: widget.accent,
                          listId: widget.list.id,
                        ),
                      ),
                    );
                    // If result is a map and has name, add item with emoji
                    if (result is Map<String, dynamic> && result['name'] != null) {
                      final api = ApiService();
                      final emoji = (result['emoji'] is String && (result['emoji'] as String).isNotEmpty)
                          ? result['emoji'] as String
                          : '🛒';
                      final itemToAdd = Map<String, dynamic>.from(result);
                      itemToAdd['emoji'] = emoji;
                      await api.addListItem(widget.list.id, itemToAdd);
                    }
                    // Always refresh after returning from add item screen
                    await _refreshListItems();
                    if (widget.onItemsChanged != null) {
                      widget.onItemsChanged!();
                    }
                  },
                  child: CustomPaint(
                    painter: _DashedRRectPainter(
                      color: Colors.grey.shade300,
                      strokeWidth: 1.6,
                      radius: 10.0,
                      dashWidth: 6.0,
                      dashSpace: 4.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 22, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Create New Item',
                            style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Grouped items by category
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    ...groupedUntickedItems.entries.expand((entry) => [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 0, 4),
                        child: Text(entry.key, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      ...entry.value.map((item) => _buildItemCard(item)),
                    ]),
                    if (checkedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 0, 4),
                        child: Text(AppLocalizations.of(context)!.completed, style: theme.textTheme.titleSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                      ...checkedItems.map((item) => _buildItemCard(item, checked: true)),
                    ],
                    if (untickedItems.isEmpty && checkedItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Center(
                          child: Text(loc.noItems, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: FooterMenu(accent: widget.accent),
        );
      }
    }
