import 'package:get/get.dart';
import 'package:watibot/modules/more/controllers/more_controller.dart';
import 'package:watibot/modules/home/controllers/home_controller.dart';
import 'package:watibot/modules/home/repositories/home_repository.dart';
import 'package:watibot/modules/inbox/controllers/inbox_controller.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';
import 'package:watibot/modules/campaigns/controllers/campaigns_controller.dart';
import 'package:watibot/modules/campaigns/repositories/campaigns_repository.dart';
import 'package:watibot/modules/contacts/controllers/contacts_controller.dart';
import 'package:watibot/modules/contacts/repositories/contacts_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepository());
    Get.lazyPut<HomeController>(() => HomeController(Get.find()));
    
    // Initialize Inbox dependencies for Bottom Nav
    Get.lazyPut<InboxRepository>(() => InboxRepository());
    Get.lazyPut<InboxController>(() => InboxController(Get.find<InboxRepository>()));

    // Initialize Campaigns dependencies for Bottom Nav
    Get.lazyPut<CampaignsRepository>(() => CampaignsRepository());
    Get.lazyPut<CampaignsController>(() => CampaignsController(Get.find<CampaignsRepository>()));

    // Initialize Contacts dependencies for Bottom Nav
    Get.lazyPut<ContactsRepository>(() => ContactsRepository());
    Get.lazyPut<ContactsController>(() => ContactsController(Get.find<ContactsRepository>()));

    // Initialize More dependencies for Bottom Nav
    Get.lazyPut<MoreController>(() => MoreController());
  }
}
