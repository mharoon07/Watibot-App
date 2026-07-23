import 'package:get/get.dart';
import 'package:watibot/modules/templates/controllers/create_template_controller.dart';
import 'package:watibot/modules/templates/repositories/templates_repository.dart';

class CreateTemplateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TemplatesRepository>(() => TemplatesRepository());
    Get.lazyPut<CreateTemplateController>(() => CreateTemplateController());
  }
}
