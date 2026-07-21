import 'package:get/get.dart';
import 'package:watibot/modules/home/controllers/notifications_controller.dart';
import 'package:watibot/modules/home/repositories/home_repository.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepository());
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}
