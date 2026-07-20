import 'package:get/get.dart';
import 'package:watibot/modules/auth/controllers/login_controller.dart';
import 'package:watibot/modules/auth/repositories/auth_repository.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository());
    }
    Get.lazyPut<LoginController>(() => LoginController(Get.find()));
  }
}
