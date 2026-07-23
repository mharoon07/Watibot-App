import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:watibot/modules/inbox/models/media_download_state.dart';

class MediaCacheService extends GetxService {
  late Box _box;
  final String _boxName = 'media_cache';

  Future<MediaCacheService> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    return this;
  }

  void saveCache(String messageId, String localPath, MediaDownloadStatus status) {
    _box.put(messageId, {
      'localPath': localPath,
      'status': status.name,
    });
  }

  Map<String, dynamic>? getCache(String messageId) {
    final data = _box.get(messageId);
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  bool isCached(String messageId) {
    final data = getCache(messageId);
    return data != null && data['status'] == MediaDownloadStatus.downloaded.name;
  }

  // Backward compatibility for AudioPlayerWidget
  bool isLoaded(String url) {
    return _box.get('audio_$url') == true;
  }

  void markAsLoaded(String url) {
    _box.put('audio_$url', true);
  }
}
