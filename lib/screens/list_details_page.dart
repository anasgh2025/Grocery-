// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/footer_menu.dart';
import 'categories_page.dart';
import '../services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../widgets/app_dialog.dart';
import '../widgets/add_item_details_sheet.dart';

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

  Future<void> _refreshListItems() async {
    try {
      final api = ApiService();
      String? listId;
      if (widget.list is Map) {
        listId = widget.list['id'] as String?;
      } else if (widget.list != null && widget.list.id != null) {
        listId = widget.list.id as String?;
      }
      if (listId == null) return;
      final items = await api.fetchListItems(listId);
      setState(() {
        if (widget.list is Map) {
          widget.list['listItems'] = items;
        } else if (widget.list != null) {
          widget.list.listItems = items;
        }
      });
    } catch (e) {
      debugPrint('Failed to refresh list items: $e');
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
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.of(context).pop();
                  final confirm = await showAppDialog<bool>(
                    context: context,
                    title: const Text('Delete Item'),
                    content: Text('Are you sure you want to delete "${item['name']}"?'),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false)),
                          const SizedBox(width: 12),
                          appDialogConfirmButton(onPressed: () => Navigator.of(context).pop(true), text: 'Delete', color: Colors.redAccent),
                        ],
                      ),
                    ],
                  );
                  if (confirm == true) {
                    await _deleteItem(item);
                  }
                  // If confirm is null or false, do nothing (dialog was cancelled)
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
        widget.list.id,
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


  Future<void> _deleteItem(Map<String, dynamic> item) async {
    try {
      final api = ApiService();
      String? listId;
      if (widget.list is Map) {
        listId = widget.list['id'] as String?;
      } else if (widget.list != null && widget.list.id != null) {
        listId = widget.list.id as String?;
      }
      if (listId == null) {
        debugPrint('Delete failed: listId is null');
        return;
      }
      await api.deleteListItem(listId, item['id']);
      await _refreshListItems();
      if (widget.onItemsChanged != null) {
        widget.onItemsChanged!();
      }
    } catch (e) {
      debugPrint('Failed to delete item: $e');
    }
  }
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
            await api.addListItem(widget.list.id, itemToAdd);
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
            // onTap removed: handled by GestureDetector in _buildItemCard
          ),
        );
      }

