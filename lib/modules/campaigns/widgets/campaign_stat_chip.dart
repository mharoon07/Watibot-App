import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const CampaignStatChip({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF0F172A),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B), // Slate
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
