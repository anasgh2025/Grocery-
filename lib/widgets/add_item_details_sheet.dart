import 'package:flutter/material.dart';
import 'box_styles.dart';
import '../l10n/app_localizations.dart';

/// A bottom sheet that collects item details before adding to the list.
/// Returns a [Map] with keys: name, qty, priority, checked.
///
/// Usage:
///   final result = await showAddItemDetailsSheet(context, itemName: 'Apple', accent: Colors.green);
///   if (result != null) { /* add item */ }
Future<Map<String, dynamic>?> showAddItemDetailsSheet(
  BuildContext context, {
  required String itemName,
  required String categoryLabel,
  required Color accent,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddItemDetailsSheet(
      itemName: itemName,
      categoryLabel: categoryLabel,
      accent: accent,
    ),
  );
}

class _AddItemDetailsSheet extends StatefulWidget {
  final String itemName;
  final String categoryLabel;
  final Color accent;
  
  const _AddItemDetailsSheet({
    required this.itemName,
    required this.categoryLabel,
    required this.accent,
    
  });

  @override
  State<_AddItemDetailsSheet> createState() => _AddItemDetailsSheetState();
}

class _AddItemDetailsSheetState extends State<_AddItemDetailsSheet> {
  String _selectedPriority = 'Normal';
  int _qty = 1;

  @override
  void dispose() {
  super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return Padding(
      // Push sheet up when keyboard appears
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: appBoxDecoration(
          context,
          color: Colors.white,
          radius: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.accent.withAlpha(31),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add_shopping_cart_rounded, color: widget.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.itemName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.categoryLabel,
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 20),

            // ── Priority selector ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.priority,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPriority = 'Urgent';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedPriority == 'Urgent'
                                  ? Colors.red[400]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.urgent,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedPriority == 'Urgent'
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPriority = 'Normal';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedPriority == 'Normal'
                                  ? Colors.blue[400]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.normal,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedPriority == 'Normal'
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Quantity stepper ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.quantity,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: _qty > 1 ? () => setState(() => _qty--) : null,
                    accent: widget.accent,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$_qty',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () => setState(() => _qty++),
                    accent: widget.accent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Add to list button ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: widget.accent,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  // No 'addToList' key in AppLocalizations, fallback to 'add' or hardcoded
                  AppLocalizations.of(context)!.add,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop<Map<String, dynamic>>({
                    'name': widget.itemName,
                    'qty': _qty,
                    'priority': _selectedPriority == 'Urgent' ? 1 : 0,
                    'checked': false,
                  });
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Small helper: quantity +/- button ────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color accent;

  const _QtyButton({required this.icon, required this.onTap, required this.accent});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: appBoxDecoration(
          context,
          color: enabled ? accent.withAlpha(31) : Colors.grey.shade100,
          radius: 10,
          border: Border.all(
            color: enabled ? accent.withAlpha(76) : Colors.grey.shade200,
          ),
          boxShadow: const [],
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? accent : Colors.grey.shade400,
        ),
      ),
    );
  }
}
