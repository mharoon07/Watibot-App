import 'package:get/get.dart';
import 'package:watibot/modules/inbox/controllers/chat_controller.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController(Get.find<InboxRepository>()));
  }
}
