import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/inbox/controllers/chat_controller.dart';
import 'package:watibot/modules/inbox/widgets/send_template_dialog.dart';

class MessageInput extends StatelessWidget {
  final ChatController chatController;

  const MessageInput({
    super.key,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Upload Progress Banner
            Obx(() {
              if (!chatController.isUploadingMedia.value) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFE0F2FE),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            chatController.uploadStatusText.value,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0369A1)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(chatController.uploadProgress.value * 100).toInt()}%',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0369A1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: chatController.uploadProgress.value,
                        backgroundColor: const Color(0xFFBAE6FD),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Live Voice Recording Bar OR Message Input Bar
            Obx(() {
              if (chatController.isRecordingVoice.value) {
                final durationSecs = chatController.voiceRecordDuration.value;
                final minutes = (durationSecs ~/ 60).toString().padLeft(2, '0');
                final seconds = (durationSecs % 60).toString().padLeft(2, '0');

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFFFEF2F2),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Recording Voice Note ($minutes:$seconds)...',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red.shade700),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: chatController.cancelVoiceRecording,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                        onPressed: chatController.stopAndSendVoiceRecording,
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF475569), size: 24),
                      onPressed: () => _showAttachmentSheet(context),
                    ),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: chatController.textController,
                                maxLines: 5,
                                minLines: 1,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                style: GoogleFonts.inter(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.attach_file, color: Color(0xFF94A3B8), size: 20),
                              onPressed: () => _showAttachmentSheet(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: chatController.textController,
                        builder: (context, value, child) {
                          final hasText = value.text.trim().isNotEmpty;
                          return IconButton(
                            icon: Icon(
                              hasText ? Icons.send : Icons.mic,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: hasText
                                ? chatController.sendMessage
                                : chatController.startVoiceRecording,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAttachmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Share Content',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  children: [
                    _buildAttachmentItem(
                      icon: Icons.camera_alt,
                      color: const Color(0xFF00B074),
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(ctx);
                        chatController.pickAndSendImage(fromCamera: true);
                      },
                    ),
                    _buildAttachmentItem(
                      icon: Icons.photo_library,
                      color: const Color(0xFF3B82F6),
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(ctx);
                        chatController.pickAndSendImage(fromCamera: false);
                      },
                    ),
                    _buildAttachmentItem(
                      icon: Icons.videocam,
                      color: const Color(0xFF8B5CF6),
                      label: 'Video',
                      onTap: () {
                        Navigator.pop(ctx);
                        chatController.pickAndSendVideo(fromCamera: false);
                      },
                    ),
                    _buildAttachmentItem(
                      icon: Icons.mic,
                      color: const Color(0xFFEF4444),
                      label: 'Voice Note',
                      onTap: () {
                        Navigator.pop(ctx);
                        chatController.startVoiceRecording();
                      },
                    ),
                    _buildAttachmentItem(
                      icon: Icons.audio_file,
                      color: const Color(0xFFF59E0B),
                      label: 'Audio File',
                      onTap: () {
                        Navigator.pop(ctx);
                        chatController.pickAndSendAudioFile();
                      },
                    ),
                    _buildAttachmentItem(
                      icon: Icons.insert_drive_file,
                      color: const Color(0xFF06B6D4),
                      label: 'Document',
                      onTap: () {
                        Navigator.pop(ctx);
                        chatController.pickAndSendDocument();
                      },
                    ),
                    _buildAttachmentItem(
                      icon: Icons.bolt,
                      color: const Color(0xFFEC4899),
                      label: 'Quick Reply',
                      onTap: () {
                        Navigator.pop(ctx);
                        _showQuickRepliesSheet(context);
                      },
                    ),
                    _buildAttachmentItem(
                      icon: Icons.article_outlined,
                      color: const Color(0xFF10B981),
                      label: 'Template',
                      onTap: () {
                        Navigator.pop(ctx);
                        _showTemplateSelectorDialog(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showQuickRepliesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Replies',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Obx(() {
                  final list = chatController.quickReplies;
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text('No quick replies available', style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 250,
                    child: ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final title = item['name']?.toString() ?? item['shortcut']?.toString() ?? 'Quick Reply ${index + 1}';
                        final content = item['content']?.toString() ?? item['text']?.toString() ?? '';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                          trailing: const Icon(Icons.send_rounded, color: AppTheme.primaryColor, size: 18),
                          onTap: () {
                            Navigator.pop(ctx);
                            chatController.sendQuickReply(item);
                          },
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTemplateSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SendTemplateDialog(
        templates: chatController.whatsappTemplates,
        onSend: (templateName, language, params, headerUrl) {
          chatController.sendWhatsAppTemplate(
            templateName: templateName,
            language: language,
            parameters: params,
            headerMediaUrl: headerUrl,
          );
        },
      ),
    );
  }
}
