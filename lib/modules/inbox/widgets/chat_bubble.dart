import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isOutgoing = message.type == MessageType.outgoing;
    final isAi = message.type == MessageType.ai;

    Color backgroundColor;
    Color textColor = AppTheme.textPrimary;
    BorderRadius borderRadius;

    if (isOutgoing) {
      backgroundColor = const Color(0xFFDCF8C6); // WhatsApp green bubble
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(4),
      );
    } else if (isAi) {
      backgroundColor = const Color(0xFFF0FDF4); // Very light green
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    } else {
      backgroundColor = Colors.white;
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isOutgoing ? 64 : 16,
          right: isOutgoing ? 16 : 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: isAi ? Border.all(color: const Color(0xFFBBF7D0), width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.senderName != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.senderName!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isAi ? const Color(0xFF059669) : const Color(0xFF3B82F6),
                    ),
                  ),
                  if (isAi) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.smart_toy, size: 12, color: Color(0xFF059669)),
                  ]
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.content,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: textColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
                if (isOutgoing) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
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
        color = const Color(0xFF3B82F6);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(icon, size: 14, color: color);
  }

  String _formatTime(DateTime time) {
    return '${time.hour > 12 ? time.hour - 12 : time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }
}
