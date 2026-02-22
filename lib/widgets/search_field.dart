import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Search field widget extracted from header
class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 2, offset: Offset(0, 1)),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(48, 15, 16, 16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Search items or lists...',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(fontSize: 14, height: 17 / 14, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
              ),
            ),
          ),

          // Left icon positioned and centered vertically
          const Positioned(
            left: 16,
            child: SizedBox(
              height: 48,
              child: Center(
                child: Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
