import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'box_styles.dart';
import '../l10n/app_localizations.dart';

/// A bottom sheet that collects item details before adding to the list.
/// Returns a [Map] with keys: name, qty, description, photoPath (nullable).
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
  double _price = 0;
  final TextEditingController _priceController = TextEditingController(text: '0');
  // Removed description controller
  XFile? _photo;
  bool _pickingPhoto = false;

  Future<void> _pickPhoto(ImageSource source) async {
    setState(() => _pickingPhoto = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 800);
      if (file != null) setState(() => _photo = file);
    } catch (e) {
      // Silently ignore (e.g. permission denied)
    } finally {
      setState(() => _pickingPhoto = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: widget.accent),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: widget.accent),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            if (_photo != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photo = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
  _priceController.dispose();
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
                    AppLocalizations.of(context)!.itemName,
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
            // ── Price input ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Price',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _price = double.tryParse(val) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Description field removed
            const SizedBox(height: 20),

            // ── Photo picker ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    // No 'photo' key in AppLocalizations, fallback to hardcoded or skip
                    'Photo',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    // No 'optional' key in AppLocalizations, fallback to hardcoded or skip
                    '(optional)',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  ),
                  const Spacer(),
                  // Thumbnail or pick button
                  GestureDetector(
                    onTap: _pickingPhoto ? null : _showPhotoOptions,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      height: 72,
                        decoration: appBoxDecoration(
                          context,
                          color: widget.accent.withAlpha(18),
                          radius: 12,
                          border: Border.all(
                            color: _photo != null ? widget.accent : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: const [],
                        ),
                      child: _pickingPhoto
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: widget.accent,
                                ),
                              ),
                            )
                          : _photo != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.file(
                                    File(_photo!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_rounded,
                                        size: 28, color: widget.accent),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.of(context)!.add,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: widget.accent),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Priority removed from details sheet (moved to category selection)
            // ── Quantity stepper ────────────────────────────────
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
                    'photoPath': _photo?.path,
                    'checked': false,
                    'price': _price,
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
