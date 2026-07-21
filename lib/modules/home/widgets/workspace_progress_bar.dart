import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkspaceProgressBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final bool isUnlimited;

  const WorkspaceProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    this.isUnlimited = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = isUnlimited ? 1.0 : (max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            Text(
              isUnlimited ? '$current / ∞' : '$current / $max',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Slate 100
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  height: 6,
                  width: constraints.maxWidth * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
