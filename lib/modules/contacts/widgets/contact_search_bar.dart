import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactSearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const ContactSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12), // CRM style slightly less rounded than campaigns
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 15,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
          suffixIcon: const Icon(Icons.filter_list, color: Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontSize: 15,
        ),
      ),
    );
  }
}
