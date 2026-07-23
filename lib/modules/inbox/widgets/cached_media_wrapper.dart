import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/services/media_download_manager.dart';
import 'package:watibot/modules/inbox/models/media_download_state.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';

class CachedMediaWrapper extends StatelessWidget {
  final MessageModel message;
  final Widget Function(String localPath) builder;
  final Widget icon;
  final String label;

  const CachedMediaWrapper({
    super.key,
    required this.message,
    required this.builder,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (message.attachmentUrl == null || message.attachmentUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    final String messageId = message.id;
    final String url = message.attachmentUrl!;
    // Extract filename from URL or fallback
    final String filename = url.split('/').last.split('?').first;

    final downloadManager = Get.find<MediaDownloadManager>();

    return Obx(() {
      final state = downloadManager.getDownloadState(messageId).value;

      if (state.status == MediaDownloadStatus.downloaded && state.localFilePath != null) {
        return builder(state.localFilePath!);
      }

      return Container(
        height: 160,
        width: 240,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Icon for Media Type
            Center(
              child: Opacity(
                opacity: 0.2,
                child: icon,
              ),
            ),
            
            // Download / Progress UI
            if (state.status == MediaDownloadStatus.notDownloaded || state.status == MediaDownloadStatus.failed)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 48),
                    onPressed: () {
                      downloadManager.downloadMedia(messageId, url, filename);
                    },
                  ),
                  Text(
                    state.status == MediaDownloadStatus.failed ? 'Retry' : label,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              )
            else if (state.status == MediaDownloadStatus.downloading)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value: state.progress > 0 ? state.progress : null,
                          color: AppTheme.primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                        onPressed: () {
                          downloadManager.cancelDownload(messageId);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(state.progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}
