import 'package:get/get.dart';
import 'package:watibot/modules/inbox/controllers/inbox_controller.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';

class InboxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InboxRepository>(() => InboxRepository());
    Get.lazyPut<InboxController>(() => InboxController(Get.find()));
  }
}
