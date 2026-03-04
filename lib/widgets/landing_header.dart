import 'package:flutter/material.dart';
// Using bundled Nunito font from assets (configured in pubspec.yaml)

/// Header: logo, avatar and search field
class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
          // Figma: padding 20px 20px 8px; gap 16px
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          color: const Color(0xFFF9FAFB),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: logo+title and avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0), // fine-tune as needed
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 28,
                            height: 28,
                            semanticLabel: 'logo',
                          ),
                      ),
                      const SizedBox(width: 10),
                      // Removed 'Grocery' text as requested
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 0),
            ],
          ),
    );
  }
}
