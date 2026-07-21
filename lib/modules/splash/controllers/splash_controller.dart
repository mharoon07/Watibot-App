import 'package:get/get.dart';
import 'package:watibot/core/services/storage_service.dart';
import 'package:watibot/modules/auth/routes/auth_routes.dart';
import 'package:watibot/modules/home/routes/home_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Animation states
  final isBackgroundReady = false.obs;
  final isLogoReady = false.obs;
  final isTextReady = false.obs;
  final isLoaderReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 1. Background softly fades in
    await Future.delayed(const Duration(milliseconds: 100));
    isBackgroundReady.value = true;

    // 2. Logo scales from 90% -> 100% and settles
    await Future.delayed(const Duration(milliseconds: 400));
    isLogoReady.value = true;

    // 3. Application title and tagline fade upward
    await Future.delayed(const Duration(milliseconds: 600));
    isTextReady.value = true;

    // 4. Subtle loading indicator begins
    await Future.delayed(const Duration(milliseconds: 500));
    isLoaderReady.value = true;

    // 5. Total wait time before navigating
    await Future.delayed(const Duration(milliseconds: 1500));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (_storageService.hasToken) {
      Get.offAllNamed(HomeRoutes.home);
    } else {
      Get.offAllNamed(AuthRoutes.login);
    }
  }
}
