import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ConversationModel conversation;

  const ChatAppBar({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leadingWidth: 72,
      leading: InkWell(
        onTap: () => Get.back(),
        borderRadius: BorderRadius.circular(50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_back_ios_new, color: Color(0xFF475569), size: 20),
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE2E8F0),
              backgroundImage: NetworkImage(conversation.displayAvatar),
            ),
          ],
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  conversation.customerName,
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (conversation.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
              ],
            ],
          ),
          Text(
            conversation.isOnline ? 'Online' : conversation.customerPhone,
            style: GoogleFonts.inter(
              color: conversation.isOnline ? const Color(0xFF10B981) : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: conversation.isOnline ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: Color(0xFF475569)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Color(0xFF475569)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF475569)),
          onPressed: () {
            // Open bottom sheet
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
