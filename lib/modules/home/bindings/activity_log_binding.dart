import 'package:get/get.dart';
import 'package:watibot/modules/home/controllers/activity_log_controller.dart';
import 'package:watibot/modules/home/repositories/home_repository.dart';

class ActivityLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepository());
    Get.lazyPut<ActivityLogController>(() => ActivityLogController());
  }
}
