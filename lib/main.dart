import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/app.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => ApiService().init());
  runApp(const App());
}
