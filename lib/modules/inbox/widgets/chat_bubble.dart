import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';
import 'package:watibot/modules/inbox/widgets/audio_player_widget.dart';
import 'package:watibot/modules/inbox/routes/inbox_routes.dart';
import 'package:watibot/modules/inbox/widgets/inline_video_player.dart';
import 'package:watibot/modules/inbox/widgets/lazy_image_widget.dart';

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
            if (message.attachmentType == AttachmentType.voice && message.attachmentUrl != null)
              AudioPlayerWidget(
                audioUrl: message.attachmentUrl!,
                isOutgoing: isOutgoing,
              )
            else if (message.content == '[Audio]' && message.attachmentUrl != null)
              AudioPlayerWidget(
                audioUrl: message.attachmentUrl!,
                isOutgoing: isOutgoing,
              )
            else if (message.attachmentType == AttachmentType.image && message.attachmentUrl != null)
              LazyImageWidget(
                imageUrl: message.attachmentUrl!,
                onTap: () => Get.toNamed(InboxRoutes.imagePreview, arguments: message.attachmentUrl!),
              )
            else if (message.content == '[Image]' && message.attachmentUrl != null)
              LazyImageWidget(
                imageUrl: message.attachmentUrl!,
                onTap: () => Get.toNamed(InboxRoutes.imagePreview, arguments: message.attachmentUrl!),
              )
            else if (message.attachmentType == AttachmentType.video && message.attachmentUrl != null)
              InlineVideoPlayer(videoUrl: message.attachmentUrl!)
            else if (message.content == '[Video]' && message.attachmentUrl != null)
              InlineVideoPlayer(videoUrl: message.attachmentUrl!)
            else if ((message.attachmentType == AttachmentType.document || message.attachmentType == AttachmentType.pdf) && message.attachmentUrl != null)
              GestureDetector(
                onTap: () => _launchUrl(message.attachmentUrl!),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file, size: 30, color: Colors.grey),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          message.content,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.download, size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              )
            else if (message.content.endsWith('.pdf') && message.attachmentUrl != null)
              GestureDetector(
                onTap: () => _launchUrl(message.attachmentUrl!),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file, size: 30, color: Colors.grey),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          message.content,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.download, size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              )
            else
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
      case MessageStatus.none:
        icon = Icons.access_time;
        color = const Color(0xFF94A3B8);
        break;
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
    }


    return Icon(icon, size: 14, color: color);
  }

  String _formatTime(DateTime time) {
    return '${time.hour > 12 ? time.hour - 12 : time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }

  Future<void> _launchUrl(String url) async {
    String finalUrl = url;
    // Force download for Cloudinary PDFs to avoid browser viewer errors
    if (url.contains('res.cloudinary.com') && url.toLowerCase().endsWith('.pdf')) {
      if (url.contains('/upload/') && !url.contains('/fl_attachment/')) {
        finalUrl = url.replaceFirst('/upload/', '/upload/fl_attachment/');
      }
    }
    final uri = Uri.parse(finalUrl);
    
    // Attempt to launch directly without canLaunchUrl check
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to launch url: $e');
    }
  }
}
