// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/scheduler.dart';
import '../models/grocery_list.dart';
import '../services/api_service.dart';
import 'create_list_dialog.dart';
import 'app_dialog.dart';
import 'box_styles.dart';
import '../screens/list_details_page.dart';
import '../l10n/app_localizations.dart';

/// Example widget showing how to use the API service to fetch lists
/// This is a stateful version that fetches data from the backend
class ListSectionWithApi extends StatefulWidget {
  const ListSectionWithApi({super.key, required this.accent});

  final Color accent;

  @override
  State<ListSectionWithApi> createState() => ListSectionWithApiState();
}

class ListSectionWithApiState extends State<ListSectionWithApi> {
  final ApiService _apiService = ApiService();
  List<GroceryList> _lists = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _attempt = 0;

  /// Called externally via GlobalKey to force a refresh.
  void refresh() => _fetchLists();

  // Helper to check if all items in a list are checked
  bool _allItemsChecked(GroceryList list) {
    final items = list.listItems;
    if (items == null || items.isEmpty) return false;
    return items.every((item) => item['checked'] == true);
  }

  @override
  void initState() {
    super.initState();
    _fetchLists();
  }

  /// Fetch lists from the backend
  Future<void> _fetchLists() async {
    const int maxAttempts = 3;
    const Duration baseDelay = Duration(milliseconds: 400);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _attempt = 0;
    });

    while (_attempt < maxAttempts) {
      _attempt++;
      try {
        // Optionally, show retry UI if needed

        final lists = await _apiService.fetchGroceryLists();
        // Sort: lists with unchecked items first, lists with all items checked last
        lists.sort((a, b) {
          final aAllChecked = _allItemsChecked(a);
          final bAllChecked = _allItemsChecked(b);
          if (aAllChecked == bAllChecked) return 0;
          return aAllChecked ? 1 : -1;
        });
        setState(() {
          _lists = lists;
          _isLoading = false;
        });
  // Helper to check if all items in a list are checked
        return;
      } catch (e) {
        // If not last attempt, wait with exponential backoff
        if (_attempt < maxAttempts) {
          final delay = baseDelay * (_attempt); // linear backoff
          await Future.delayed(delay);
          continue;
        }

        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          // Optionally, show retry UI if needed
        });
        // Show a SnackBar so the user sees the error immediately (use post frame to
        // avoid using the BuildContext across async gaps).
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted && _errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load lists: $_errorMessage')),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;
    if (_isLoading) {
      mainContent = SliverToBoxAdapter(
        child: SizedBox(
          height: 180,
          child: Center(
            child: _errorMessage == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Failed to load lists'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchLists,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
          ),
        ),
      );
    } else if (_lists.isEmpty) {
      mainContent = SliverPadding(
        padding: const EdgeInsets.only(left: 0, top: 0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildCreateListCard(),
            childCount: 1,
          ),
        ),
      );
    } else {
      mainContent = SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) return _buildCreateListCard();
            final list = _lists[index - 1];
            final allChecked = _allItemsChecked(list);
            final total = list.listItems?.length ?? 0;
            final checked = list.listItems?.where((item) => item['checked'] == true).length ?? 0;
            final itemLabel = total > 0 ? '$checked/$total' : 'No items';
            return RepaintBoundary(
              child: _ListCard(
                key: ValueKey(list.id),
                list: list,
                onTap: () async {
                  final latestLists = await _apiService.fetchGroceryLists();
                  final latest = latestLists.firstWhere(
                    (l) => l.id == list.id,
                    orElse: () => list,
                  );
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ListDetailsPage(
                        list: latest,
                        accent: widget.accent,
                        onItemsChanged: _fetchLists,
                      ),
                    ),
                  );
                  if (result == true) {
                    await _fetchLists();
                  }
                },
                allChecked: allChecked,
                total: total,
                checked: checked,
                itemLabel: itemLabel,
                bgAsset: null,
                onDelete: (ctx) {
                  showAppDialog<bool>(
                    context: ctx,
                    title: const Text('Delete List'),
                    content: const Text('Are you sure you want to delete this list? This action cannot be undone.'),
                    actions: [
                      appDialogCancelButton(onPressed: () => Navigator.of(ctx).pop()),
                      appDialogConfirmButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop(true);
                          try {
                            await _apiService.deleteGroceryList(list.id);
                            await _fetchLists();
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('List deleted successfully.')),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('Failed to delete list: $e')),
                              );
                            }
                          }
                        },
                        text: 'Delete',
                        color: Colors.red,
                      ),
                    ],
                  );
                },
                onShare: (ctx) {
                  final listName = list.name;
                  final items = (list.listItems is List) ? list.listItems as List : [];
                  final itemsText = items.isNotEmpty
                    ? items.map((item) {
                        final name = item['name'] ?? '';
                        final qty = item['qty'] != null ? ' (Qty: ${item['qty']})' : '';
                        return '• $name$qty';
                      }).join('\n')
                    : 'No items in the list.';
                  final shareText = 'Here is the list of $listName\n$itemsText\n\nThank you for using the app';
                  final box = ctx.findRenderObject() as RenderBox?;
                  if (box != null) {
                    Share.share(
                      shareText,
                      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                    );
                  } else {
                    Share.share(shareText);
                  }
                },
              ),
            );
          },
          childCount: _lists.length + 1,
          findChildIndexCallback: (key) {
            if (key == const ValueKey('create')) return 0;
            final id = (key as ValueKey<String>).value;
            final i = _lists.indexWhere((l) => l.id == id);
            return i < 0 ? null : i + 1;
          },
        ),
      );
    }
    return mainContent;
  }
  Widget _buildCreateListCard() {
    return GestureDetector(
      key: const ValueKey('create'),
      onTap: () async {
        final created = await showModalBottomSheet<GroceryList>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                      minWidth: 320,
                    ),
                    child: Container(
                      decoration: appBoxDecoration(
                        context,
                        color: Colors.white,
                        radius: 20,
                      ),
                      child: SingleChildScrollView(
                        controller: controller,
                        child: CreateListDialog(
                          accent: widget.accent,
                          onListCreated: () => _fetchLists(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
        if (created != null) {
          await _fetchLists();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('List "${created.name}" created successfully!'),
              backgroundColor: widget.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(24),
            ),
          );
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, size: 24, color: Colors.grey),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.createNewList,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter that draws a dashed rounded rectangle border.
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.6,
    this.radius = 10.0,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
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
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Isolated card widget — StatelessWidget so Flutter can skip rebuilding cards
// that haven't changed. RepaintBoundary in the parent ensures its layer is
// cached and not repainted during scroll.
// ─────────────────────────────────────────────────────────────────────────────
class _ListCard extends StatelessWidget {
  const _ListCard({
    super.key,
    required this.list,
    required this.onTap,
    required this.allChecked,
    required this.total,
    required this.checked,
    required this.itemLabel,
    required this.bgAsset,
    required this.onDelete,
    required this.onShare,
  });

  final GroceryList list;
  final void Function() onTap;
  final bool allChecked;
  final int total;
  final int checked;
  final String itemLabel;
  final String? bgAsset;
  final void Function(BuildContext) onDelete;
  final void Function(BuildContext) onShare;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Base card decoration
          Container(
            padding: const EdgeInsets.all(5),
            decoration: appBoxDecoration(
              context,
              color: Colors.white,
              radius: 12,
            ),
          ),
          // Card content
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── Icon + due-date row ─────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // No icon or emoji
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    list.time,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (allChecked)
                              const Icon(Icons.check_circle, size: 20, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          list.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    // ── Item count + price + status/urgent icon ─────────────
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                itemLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (total > 0 && checked < total)
                          const Icon(Icons.error_outline, size: 20, color: Colors.redAccent),
                      ],
                    ),
                  ],
                ),
                // ── Popup menu for actions ─────────────────────
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete(context);
                      } else if (value == 'share') {
                        onShare(context);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'share',
                        child: ListTile(
                          leading: const Icon(Icons.share),
                          title: Text(AppLocalizations.of(context)!.share),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
