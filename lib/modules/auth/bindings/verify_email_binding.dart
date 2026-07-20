import 'package:get/get.dart';
import 'package:watibot/modules/auth/controllers/verify_email_controller.dart';
import 'package:watibot/modules/auth/repositories/auth_repository.dart';

class VerifyEmailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository());
    }
    Get.lazyPut<VerifyEmailController>(() => VerifyEmailController(Get.find()));
  }
}
