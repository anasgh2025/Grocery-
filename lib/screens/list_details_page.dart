
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/footer_menu.dart';
import 'categories_page.dart';
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
      final cat = item['category'] ?? 'Other';
      grouped.putIfAbsent(cat, () => []).add(item);
    }
    return grouped;
  }

  void _onSearchChanged(String value) async {
    setState(() {
      _showSuggestions = value.isNotEmpty;
      _loadingSuggestions = true;
    });
    // TODO: Call your API for suggestions
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _suggestions = [];
      _loadingSuggestions = false;
    });
  }

  void _onTapSuggestion(Map<String, dynamic> suggestion) {
    // TODO: Add item from suggestion
    setState(() {
      _showSuggestions = false;
      _searchController.clear();
    });
  }

      void _onQuantityTap(Map<String, dynamic> item) async {
        // TODO: Show dialog to change quantity
      }

      void _onFavoriteTap(Map<String, dynamic> item) {
        // TODO: Mark as favorite
      }

      void _onPhotoTap(Map<String, dynamic> item) {
        // TODO: Add photo
      }

      void _onDeleteItem(Map<String, dynamic> item) {
        // TODO: Delete item
      }

      void _onCheckChanged(Map<String, dynamic> item, bool? checked) {
        setState(() {
          item['checked'] = checked == true;
        });
        if (widget.onItemsChanged != null) {
          widget.onItemsChanged!();
        }
      }

      Widget _buildItemCard(Map<String, dynamic> item, {bool checked = false}) {
        final theme = Theme.of(context);
        final emoji = item['emoji'] as String?;
        return Dismissible(
          key: ValueKey(item['id'] ?? item['name']),
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.blue.shade100,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_camera),
                  onPressed: () => _onPhotoTap(item),
                ),
                IconButton(
                  icon: const Icon(Icons.star_border),
                  onPressed: () => _onFavoriteTap(item),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              _onDeleteItem(item);
              return true;
            } else if (direction == DismissDirection.endToStart) {
              return false;
            }
            return false;
          },
          child: GestureDetector(
            onTap: () => _onCheckChanged(item, !(item['checked'] == true)),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: (emoji != null && emoji.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      )
                    : null,
                title: Text(
                  item['name']?.toString() ?? '',
                  style: (item['checked'] == true)
                      ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
                      : theme.textTheme.bodyLarge,
                ),
                subtitle: GestureDetector(
                  onTap: () => _onQuantityTap(item),
                  child: item['qty'] != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Qty: ${item['qty']}'),
                            const SizedBox(width: 8),
                            const Icon(Icons.edit, size: 14, color: Colors.grey),
                          ],
                        )
                      : null,
                ),
                trailing: (item['checked'] == true)
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
            ),
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
                          boxShadow: [
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoriesPage(
                          accent: widget.accent,
                          listId: widget.list.id,
                        ),
                      ),
                    );
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline, size: 22, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Create New Item',
                            style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
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
