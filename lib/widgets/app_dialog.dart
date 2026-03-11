import 'package:flutter/material.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required List<Widget> actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: title,
      content: content,
      actions: actions,
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      titleTextStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black,
      ),
    ),
  );
}

Widget appDialogCancelButton({required VoidCallback onPressed, String text = 'Cancel'}) {
  return TextButton(
    onPressed: onPressed,
    child: Text(text, style: const TextStyle(color: Colors.red)),
  );
}

Widget appDialogConfirmButton({required VoidCallback onPressed, required String text, Color? color}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color ?? Colors.green,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    onPressed: onPressed,
    child: Text(text),
  );
}
