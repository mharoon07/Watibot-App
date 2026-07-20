import 'package:get/get.dart';
import 'package:watibot/modules/campaigns/controllers/campaigns_controller.dart';
import 'package:watibot/modules/campaigns/repositories/campaigns_repository.dart';

class CampaignsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CampaignsRepository>(() => CampaignsRepository());
    Get.lazyPut<CampaignsController>(() => CampaignsController(Get.find()));
  }
}
