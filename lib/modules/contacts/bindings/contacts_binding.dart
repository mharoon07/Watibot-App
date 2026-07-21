import 'package:get/get.dart';
import 'package:watibot/modules/contacts/controllers/contacts_controller.dart';
import 'package:watibot/modules/contacts/repositories/contacts_repository.dart';

class ContactsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContactsRepository>(() => ContactsRepository());
    Get.lazyPut<ContactsController>(() => ContactsController());
  }
}
