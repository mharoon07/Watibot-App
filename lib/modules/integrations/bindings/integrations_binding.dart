import 'package:get/get.dart';
import 'package:watibot/modules/integrations/controllers/integrations_controller.dart';

class IntegrationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IntegrationsController>(() => IntegrationsController());
  }
}
