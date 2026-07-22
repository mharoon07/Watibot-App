import 'package:get/get.dart';
import 'package:watibot/modules/media_library/controllers/media_library_controller.dart';

class MediaLibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaLibraryController>(() => MediaLibraryController());
  }
}
