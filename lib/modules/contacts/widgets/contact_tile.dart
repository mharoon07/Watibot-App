import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:watibot/modules/contacts/models/contact_model.dart';
import 'package:watibot/modules/contacts/widgets/contact_avatar.dart';
import 'package:watibot/modules/contacts/widgets/contact_status_badge.dart';

class ContactTile extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onFavorite;
  final VoidCallback onBlock;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onCall,
    required this.onChat,
    required this.onFavorite,
    required this.onBlock,
    required this.onDelete,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if contact is online (seen in last 10 mins)
    final isOnline = DateTime.now().difference(contact.lastSeen).inMinutes <= 10;

    return Slidable(
      key: ValueKey(contact.id),
      // Left side actions (Swipe Right)
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.6,
        children: [
          SlidableAction(
            onPressed: (_) => onCall(),
            backgroundColor: const Color(0xFF3B82F6), // Blue
            foregroundColor: Colors.white,
            icon: Icons.call_outlined,
            label: 'Call',
          ),
          SlidableAction(
            onPressed: (_) => onChat(),
            backgroundColor: const Color(0xFF25D366), // WhatsApp Green
            foregroundColor: Colors.white,
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
          ),
          SlidableAction(
            onPressed: (_) => onFavorite(),
            backgroundColor: const Color(0xFFF59E0B), // Amber
            foregroundColor: Colors.white,
            icon: contact.isFavorite ? Icons.star : Icons.star_border,
            label: 'Favorite',
          ),
        ],
      ),
      // Right side actions (Swipe Left)
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.6,
        children: [
          SlidableAction(
            onPressed: (_) => onArchive(),
            backgroundColor: const Color(0xFF64748B), // Slate
            foregroundColor: Colors.white,
            icon: Icons.archive_outlined,
            label: 'Archive',
          ),
          SlidableAction(
            onPressed: (_) => onBlock(),
            backgroundColor: const Color(0xFFF97316), // Orange
            foregroundColor: Colors.white,
            icon: Icons.block_outlined,
            label: 'Block',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: const Color(0xFFEF4444), // Red
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContactAvatar(
                imageUrl: contact.avatarUrl,
                name: contact.name,
                size: 48,
                isOnline: isOnline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (contact.isWhatsappVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Color(0xFF25D366), size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${contact.company.isNotEmpty ? '${contact.company} • ' : ''}${contact.phone}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ContactStatusBadge(status: contact.status),
                        if (contact.tags.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '+${contact.tags.length}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      if (contact.isFavorite)
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                      if (contact.isFavorite) const SizedBox(width: 4),
                      Text(
                        _formatDate(contact.lastInteraction),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: contact.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                          color: contact.unreadCount > 0 ? const Color(0xFF25D366) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  if (contact.unreadCount > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        contact.unreadCount.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      return DateFormat.jm().format(date);
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
