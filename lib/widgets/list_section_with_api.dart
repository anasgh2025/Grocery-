import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
            // Show two cards per row on the landing page
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            // Slightly taller cards to suit two-column layout on mobile
            childAspectRatio: 1.12,
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
        // Two columns keeps rows balanced on most phone widths
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Card is slightly taller to better fit two-up layout
        childAspectRatio: 1.12,
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

          // If a list was created, refresh and show a simple confirmation dialog
          if (created != null) {
            await _fetchLists();

            if (!mounted) return;

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: widget.accent),
                    const SizedBox(height: 16),
                    Text(
                      'List Created!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${created.name}" has been created successfully.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          }
        }();
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
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
    final (checked, total) = _itemCounts;
    final bool allChecked = total > 0 && checked == total;

    final isParty = list.name.toLowerCase().contains('party') ||
        list.icon == Icons.celebration ||
        list.icon == Icons.celebration_outlined;

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
          // Party background image (falls back gracefully if asset missing)
          if (isParty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/Party.png',
                      fit: BoxFit.cover,
                      // If the asset isn't present, don't crash — just ignore the image.
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                    // Gentle gradient overlay to keep text readable on bright images
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [Color(0x88000000), Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Card content
          Container(
            padding: const EdgeInsets.all(5),
            // Ensure content sits above the background image
            decoration: BoxDecoration(color: Colors.transparent),
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
            // ── Item count + status/urgent icon ─────────────────
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
                if (allChecked)
                  const Icon(Icons.check_circle, size: 20, color: Colors.green)
                else if (list.priority == 1)
                  const Icon(Icons.priority_high, size: 18, color: Colors.redAccent)
                else if (total > 0 && checked < total)
                  const Icon(Icons.error_outline, size: 20, color: Colors.redAccent),
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
    ],
  ),
); 
  }
}
