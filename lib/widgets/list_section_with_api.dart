import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/grocery_list.dart';
import '../services/api_service.dart';
import 'create_list_dialog.dart';
import 'box_styles.dart';
import '../screens/list_details_page.dart';

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
  bool _isRetrying = false;
  int _attempt = 0;

  /// Called externally via GlobalKey to force a refresh.
  void refresh() => _fetchLists();

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
      _isRetrying = false;
      _attempt = 0;
    });

    while (_attempt < maxAttempts) {
      _attempt++;
      try {
        if (_attempt > 1) {
          setState(() {
            _isRetrying = true;
          });
        }

        final lists = await _apiService.fetchGroceryLists();
        setState(() {
          _lists = lists;
          _isLoading = false;
          _isRetrying = false;
        });
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
          _isRetrying = false;
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
    // ── Loading state ──────────────────────────────────────────────────────
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 180,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: widget.accent),
                if (_isRetrying) ...[
                  const SizedBox(height: 12),
                  Text('Retrying... attempt $_attempt'),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // ── Error state ────────────────────────────────────────────────────────
    if (_errorMessage != null) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
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
    }

    // ── Empty state ────────────────────────────────────────────────────────
    if (_lists.isEmpty) {
      // Show the create-card in the top-left (first grid position).
      return SliverPadding(
        padding: const EdgeInsets.only(left: 0, top: 0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 1.05,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildCreateListCard(),
            childCount: 1,
          ),
        ),
      );
    }

    // ── Grid — the only thing returned when data is loaded ─────────────────
    // No SliverMainAxisGroup, no header sliver, no dynamic object construction.
    // A bare SliverGrid is layout-stable across scroll frames.
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 1.05,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) return _buildCreateListCard();
          return RepaintBoundary(
            child: _ListCard(
              key: ValueKey(_lists[index - 1].id),
              list: _lists[index - 1],
              accent: widget.accent,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ListDetailsPage(
                      list: _lists[index - 1],
                      accent: widget.accent,
                      onItemsChanged: _fetchLists,
                      onListDeleted: _fetchLists,
                    ),
                  ),
                );
              },
            ),
          );
        },
        childCount: _lists.length + 1,
        // Stable key → Flutter reuses existing render objects instead of
        // recreating them, which eliminates the position-jump on rebuild.
        findChildIndexCallback: (key) {
          if (key == const ValueKey('create')) return 0;
          final id = (key as ValueKey<String>).value;
          final i = _lists.indexWhere((l) => l.id == id);
          return i < 0 ? null : i + 1;
        },
      ),
    );
  }

  Widget _buildCreateListCard() {
    return GestureDetector(
      key: const ValueKey('create'),
      onTap: () {
        () async {
          // Open as a half-screen modal bottom sheet
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
                  return Container(
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
                  );
                },
              );
            },
          );

          // If a list was created, refresh and show it in a pull-up details sheet
          if (created != null) {
            await _fetchLists();

            if (!mounted) return;

            // Show a small bottom sheet with the created list details
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (ctx) => Container(
                padding: const EdgeInsets.all(16),
                decoration: appBoxDecoration(
                  ctx,
                  color: Colors.white,
                  radius: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'List created',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(created.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(created.icon, color: widget.accent, size: 24),
                        const SizedBox(width: 8),
                        Text(created.time, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Priority: ${created.progress == 0.0 ? 'Normal' : 'Urgent'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('${created.items} items', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.accent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Done'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () async {
                                  final inviteText = 'Join my grocery list "${created.name}" - open the app to view it.';
                                  try {
                                    // Use the bottom sheet's context (`ctx`) to provide a valid sharePositionOrigin
                                    final box = ctx.findRenderObject() as RenderBox;
                                    final offset = box.localToGlobal(Offset.zero);
                                    final origin = Rect.fromLTWH(offset.dx, offset.dy, box.size.width, box.size.height);
                                    await Share.share(inviteText, subject: 'Grocery list invite', sharePositionOrigin: origin);
                                  } catch (e) {
                                    // Fallback: call share without position if anything goes wrong
                                    await Share.share(inviteText, subject: 'Grocery list invite');
                                  }
                                },
                          child: const Text('Invite'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1.6),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 24, color: Colors.grey),
            SizedBox(height: 6),
            Text(
              'Create\nNew List',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
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
    required this.accent,
    required this.onTap,
  });

  final GroceryList list;
  final Color accent;
  final VoidCallback onTap;

  // Compute item counts once at build time — no Builder/try-catch per frame.
  (int checked, int total) get _itemCounts {
    final items = list.listItems ?? [];
    if (items.isEmpty) {
      // list.items is a display string like "5 items" — extract the number
      final n = int.tryParse(list.items.split(' ').first) ?? 0;
      return (0, n);
    }
    int total = items.length;
    int checked = 0;
    for (final it in items) {
      if (it['checked'] == true || it['done'] == true) checked++;
    }
    return (checked, total);
  }

  String get _itemLabel {
    final items = list.listItems ?? [];
    if (items.isEmpty) return list.items; // use the raw display string
    final (checked, total) = _itemCounts;
    return '$checked/$total items';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUrgent = list.progress >= 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: appBoxDecoration(
          context,
          color: Colors.white,
          radius: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Icon + due-date row ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(list.icon, color: accent, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    list.time,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // ── Title ───────────────────────────────────────────
            Text(
              list.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // ── Item count + urgent icon ─────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    _itemLabel,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                if (isUrgent)
                  const Icon(Icons.priority_high, size: 24, color: Colors.redAccent),
              ],
            ),
            const SizedBox(height: 2),
            // ── Static progress bar (no animation = no repaint) ──
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 3.5,
                child: Row(
                  children: [
                    Flexible(
                      flex: (list.progress.clamp(0.0, 1.0) * 1000).round(),
                      child: Container(color: accent),
                    ),
                    Flexible(
                      flex: ((1.0 - list.progress.clamp(0.0, 1.0)) * 1000).round(),
                      child: const ColoredBox(color: Color(0xFFE5E7EB)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }
}
