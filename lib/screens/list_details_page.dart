import 'package:flutter/material.dart';
import '../screens/categories_page.dart';
import '../services/api_service.dart';
import '../widgets/box_styles.dart';

class ListDetailsPage extends StatefulWidget {
  final dynamic list;
  final Color accent;
  final Function? onItemsChanged;
  const ListDetailsPage({Key? key, required this.list, required this.accent, this.onItemsChanged}) : super(key: key);

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
}

class _ListDetailsPageState extends State<ListDetailsPage> {
  final TextEditingController _addItemController = TextEditingController();
  final ApiService _api = ApiService();
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems({bool notifyParent = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.fetchListItems(widget.list.id);
      setState(() {
        _items = items;
        _loading = false;
      });
      if (notifyParent && widget.onItemsChanged != null) {
        widget.onItemsChanged!();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _addItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name ?? '', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            onSelected: (value) {
              if (value == 'delete') {} // implement delete
              if (value == 'share') {} // implement share
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: const [
                    Icon(Icons.share_outlined, color: Colors.black87, size: 20),
                    SizedBox(width: 10),
                    Text('Share list'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: const [
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Failed to load items.\n$_error', textAlign: TextAlign.center))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.12,
                    ),
                    itemCount: _items.length + 1, // +1 for Add New Item card
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Add New Item card always first
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CategoriesPage(
                                  accent: widget.accent,
                                  listId: widget.list.id,
                                ),
                              ),
                            );
                            if (result == true) {
                              _fetchItems();
                            }
                          },
                          child: CustomPaint(
                            painter: DashedRRectPainter(
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
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 32, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Add New Item', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      // Item card (shifted by -1)
                      final item = _items[index - 1];
                      final isChecked = item['checked'] == true;
                      return GestureDetector(
                        onTap: () async {
                          try {
                            await _api.updateListItem(
                              widget.list.id,
                              item['id'],
                              {'checked': !isChecked},
                            );
                            _fetchItems(notifyParent: true);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update item: $e')),
                              );
                            }
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isChecked ? Colors.grey[300] : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.shopping_bag_outlined, color: widget.accent, size: 28),
                                      const Spacer(),
                                      if (isChecked)
                                        const Icon(Icons.check_circle, color: Colors.green, size: 22),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['name'] ?? '',
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item['qty'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text('Qty: ${item['qty']}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
