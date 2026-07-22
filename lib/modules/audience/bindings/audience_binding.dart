import 'package:get/get.dart';
import 'package:watibot/modules/audience/controllers/audience_controller.dart';

class AudienceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AudienceController>(() => AudienceController());
  }
}
