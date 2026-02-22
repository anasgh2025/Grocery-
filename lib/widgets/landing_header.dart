import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
                      // Logo background circle with shadow (32x32)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935), // #E53935
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Color(0x29E53935), blurRadius: 15, offset: Offset(0, 10)),
                                BoxShadow(color: Color(0x29E53935), blurRadius: 6, offset: Offset(0, 4)),
                              ],
                            ),
                          ),
                          // Small logo icon inside
                          SvgPicture.asset(
                            'assets/images/logo.svg',
                            width: 18.3,
                            height: 15.8,
                            semanticsLabel: 'logo',
                          ),
                        ],
                      ),

                      const SizedBox(width: 8),

                      // Heading text
                      Text(
                        'Grocery',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            height: 28 / 20,
                            letterSpacing: -0.5,
                            color: Color(0xFF1A1C1E),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Avatar image with white border and shadow (40x40)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade100, child: const Icon(Icons.person, color: Colors.black38, size: 26)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 0),
            ],
          ),
    );
  }
}
