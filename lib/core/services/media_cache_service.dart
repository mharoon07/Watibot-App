import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaCacheService extends GetxService {
  late SharedPreferences _prefs;
  final String _cacheKey = 'loaded_media_urls';
  final Set<String> _loadedUrls = {};

  Future<MediaCacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    final cached = _prefs.getStringList(_cacheKey) ?? [];
    _loadedUrls.addAll(cached);
    return this;
  }

  bool isLoaded(String url) {
    return _loadedUrls.contains(url);
  }

  Future<void> markAsLoaded(String url) async {
    if (!_loadedUrls.contains(url)) {
      _loadedUrls.add(url);
      await _prefs.setStringList(_cacheKey, _loadedUrls.toList());
    }
  }
}
