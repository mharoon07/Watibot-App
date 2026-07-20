import 'package:get/get.dart';
import 'package:watibot/modules/auth/controllers/forgot_password_controller.dart';
import 'package:watibot/modules/auth/repositories/auth_repository.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository());
    }
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController(Get.find()));
  }
}
