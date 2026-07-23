import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _formatDate(date),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime utcDate) {
    final d = utcDate.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(d.year, d.month, d.day);

    if (targetDate == today) return 'Today';
    if (targetDate == yesterday) return 'Yesterday';

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (now.difference(d).inDays < 7) {
      return days[d.weekday - 1];
    }
    return '${d.month}/${d.day}/${d.year}';
  }
}
