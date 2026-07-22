import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/app.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/core/services/storage_service.dart';

import 'package:watibot/core/services/media_cache_service.dart';
import 'package:watibot/core/services/chat_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Get.putAsync(() => StorageService().init());
    await Get.putAsync(() => ApiService().init());
    await Get.putAsync(() => MediaCacheService().init());
    await Get.putAsync(() => ChatCacheService().init());
  } catch (e) {
    debugPrint('Service init error: $e');
  }
  runApp(const App());
}

