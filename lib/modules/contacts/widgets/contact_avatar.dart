import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double size;
  final bool isOnline;

  const ContactAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 48,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF1F5F9), // Slate 100
            image: imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl.isEmpty
              ? Center(
                  child: Text(
                    _getInitials(name),
                    style: GoogleFonts.inter(
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B), // Slate 500
                    ),
                  ),
                )
              : null,
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}
