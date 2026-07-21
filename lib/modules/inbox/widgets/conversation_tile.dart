import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';
import 'package:watibot/modules/inbox/routes/inbox_routes.dart';
import 'package:watibot/modules/inbox/widgets/unread_badge.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onArchive;
  final VoidCallback onPin;
  final VoidCallback onMarkRead;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onArchive,
    required this.onPin,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(conversation.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onArchive(),
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF475569),
            icon: Icons.archive_outlined,
            label: 'Archive',
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => onPin(),
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            foregroundColor: AppTheme.primaryColor,
            icon: conversation.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: conversation.isPinned ? 'Unpin' : 'Pin',
          ),
          SlidableAction(
            onPressed: (_) => onMarkRead(),
            backgroundColor: const Color(0xFFEFF6FF),
            foregroundColor: const Color(0xFF3B82F6),
            icon: conversation.unreadCount > 0 ? Icons.mark_chat_read_outlined : Icons.mark_chat_unread_outlined,
            label: conversation.unreadCount > 0 ? 'Read' : 'Unread',
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(InboxRoutes.chat, arguments: conversation),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopRow(),
                    const SizedBox(height: 4),
                    _buildBottomRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFE2E8F0),
          backgroundImage: NetworkImage(conversation.displayAvatar),
        ),
        if (conversation.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  conversation.customerName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (conversation.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
              ],
              if (conversation.isPinned) ...[
                const SizedBox(width: 4),
                const Icon(Icons.push_pin, color: Color(0xFF94A3B8), size: 16),
              ],
            ],
          ),
        ),
        Text(
          conversation.lastMessage != null ? _formatTime(conversation.lastMessage!.timestamp) : '',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
            color: conversation.unreadCount > 0 ? AppTheme.primaryColor : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    if (conversation.lastMessage == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (conversation.lastMessage!.type == MessageType.outgoing)
          _buildMessageStatus(conversation.lastMessage!.status),
        Expanded(
          child: Text(
            conversation.lastMessage!.content,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
              color: conversation.unreadCount > 0 ? AppTheme.textPrimary : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (conversation.priority == 'high') ...[
          const SizedBox(width: 8),
          const Icon(Icons.error, color: Color(0xFFEF4444), size: 16),
        ],
        if (conversation.unreadCount > 0) ...[
          const SizedBox(width: 8),
          UnreadBadge(count: conversation.unreadCount),
        ],
      ],
    );
  }

  Widget _buildMessageStatus(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = const Color(0xFF94A3B8);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = const Color(0xFF94A3B8);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = const Color(0xFF3B82F6); // Blue ticks
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(icon, size: 16, color: color),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour > 12 ? time.hour - 12 : time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      if (now.difference(time).inDays < 7) {
        return days[time.weekday - 1];
      }
      return '${time.month}/${time.day}/${time.year}';
    }
  }
}
