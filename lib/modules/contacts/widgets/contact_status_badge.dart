import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/contacts/models/contact_model.dart';

class ContactStatusBadge extends StatelessWidget {
  final String status;

  const ContactStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'customer':
        bgColor = const Color(0xFFE0F2FE); // Light Sky
        textColor = const Color(0xFF0284C7); // Sky
        label = 'Customer';
        break;
      case 'lead':
        bgColor = const Color(0xFFFEF3C7); // Light Amber
        textColor = const Color(0xFFD97706); // Amber
        label = 'Lead';
        break;
      case 'vip':
        bgColor = const Color(0xFFF3E8FF); // Light Purple
        textColor = const Color(0xFF9333EA); // Purple
        label = 'VIP';
        break;
      case 'blocked':
        bgColor = const Color(0xFFFEE2E2); // Light Red
        textColor = const Color(0xFFDC2626); // Red
        label = 'Blocked';
        break;
      case 'unknown':
      default:
        bgColor = const Color(0xFFF1F5F9); // Light Slate
        textColor = const Color(0xFF64748B); // Slate
        label = status.isNotEmpty ? status : 'Unknown';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
