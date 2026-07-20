import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreSectionHeader extends StatelessWidget {
  final String title;

  const MoreSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF94A3B8), // Slate 400
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
