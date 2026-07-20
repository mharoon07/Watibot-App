import 'package:get/get.dart';
import 'package:watibot/modules/auth/controllers/register_controller.dart';
import 'package:watibot/modules/auth/repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository());
    }
    Get.lazyPut<RegisterController>(() => RegisterController(Get.find()));
  }
}
