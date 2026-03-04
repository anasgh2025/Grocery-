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
                    children: [
                      Image.asset(
                        'assets/images/Logo.png',
                        width: 18.3,
                        height: 15.8,
                        semanticLabel: 'logo',
                      ),
                      const SizedBox(width: 8),

                      // Heading text
                      const Text(
                        'Grocery',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          height: 28 / 20,
                          letterSpacing: -0.5,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
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
