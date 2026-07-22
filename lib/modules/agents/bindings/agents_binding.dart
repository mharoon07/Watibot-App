import 'package:get/get.dart';
import 'package:watibot/modules/agents/controllers/agents_controller.dart';

class AgentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgentsController>(() => AgentsController());
  }
}
