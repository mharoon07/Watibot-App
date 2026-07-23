import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watibot/core/services/media_cache_service.dart';
import 'package:watibot/modules/inbox/models/media_download_state.dart';
import 'package:watibot/core/services/api_service.dart';

class MediaDownloadManager extends GetxService {
  final MediaCacheService _cacheService = Get.find<MediaCacheService>();
  final Dio _dio = Dio();

  // Maps messageId to its current download state
  final Map<String, Rx<MediaDownloadState>> _downloadStates = {};

  // Maps messageId to its cancellation token
  final Map<String, CancelToken> _cancelTokens = {};

  Rx<MediaDownloadState> getDownloadState(String messageId) {
    if (!_downloadStates.containsKey(messageId)) {
      // Initialize state from cache if exists
      final cached = _cacheService.getCache(messageId);
      if (cached != null) {
        final statusStr = cached['status'] as String;
        final localPath = cached['localPath'] as String;
        
        MediaDownloadStatus status = MediaDownloadStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => MediaDownloadStatus.notDownloaded,
        );

        // Verify file actually exists
        if (status == MediaDownloadStatus.downloaded && !File(localPath).existsSync()) {
          status = MediaDownloadStatus.notDownloaded;
        }

        if (status == MediaDownloadStatus.downloaded) {
          _downloadStates[messageId] = Rx<MediaDownloadState>(MediaDownloadState.downloaded(localPath));
        } else if (status == MediaDownloadStatus.failed) {
          _downloadStates[messageId] = Rx<MediaDownloadState>(MediaDownloadState.failed());
        } else {
          _downloadStates[messageId] = Rx<MediaDownloadState>(MediaDownloadState.notDownloaded());
        }
      } else {
        _downloadStates[messageId] = Rx<MediaDownloadState>(MediaDownloadState.notDownloaded());
      }
    }
    return _downloadStates[messageId]!;
  }

  Future<void> downloadMedia(String messageId, String url, String originalFileName) async {
    final state = getDownloadState(messageId);
    
    if (state.value.status == MediaDownloadStatus.downloading || 
        state.value.status == MediaDownloadStatus.downloaded) {
      return; // Already downloading or downloaded
    }

    state.value = MediaDownloadState.downloading(0.0);
    final cancelToken = CancelToken();
    _cancelTokens[messageId] = cancelToken;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final chatMediaDir = Directory('${appDir.path}/chat_media');
      if (!await chatMediaDir.exists()) {
        await chatMediaDir.create(recursive: true);
      }

      final ext = originalFileName.contains('.') ? originalFileName.split('.').last : 'bin';
      final savePath = '${chatMediaDir.path}/${messageId}_media.$ext';

      // Use the sanitized URL and headers if it's from our API
      String sanitizedUrl = url;
      if (url.startsWith('http://localhost:3000')) {
        sanitizedUrl = url.replaceFirst('http://localhost:3000', ApiService.baseUrl.replaceAll('/api/v1', ''));
      }
      
      final headers = ApiService.getMediaHeaders(sanitizedUrl);

      await _dio.download(
        sanitizedUrl,
        savePath,
        cancelToken: cancelToken,
        options: Options(headers: headers),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            state.value = MediaDownloadState.downloading(received / total);
          }
        },
      );

      state.value = MediaDownloadState.downloaded(savePath);
      _cacheService.saveCache(messageId, savePath, MediaDownloadStatus.downloaded);
      
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        state.value = MediaDownloadState.notDownloaded();
      } else {
        state.value = MediaDownloadState.failed();
        _cacheService.saveCache(messageId, '', MediaDownloadStatus.failed);
      }
    } finally {
      _cancelTokens.remove(messageId);
    }
  }

  void cancelDownload(String messageId) {
    if (_cancelTokens.containsKey(messageId)) {
      _cancelTokens[messageId]!.cancel();
      _cancelTokens.remove(messageId);
      final state = getDownloadState(messageId);
      state.value = MediaDownloadState.notDownloaded();
    }
  }
}
