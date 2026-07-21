import 'package:get/get.dart';
import 'package:watibot/core/services/storage_service.dart';
import 'package:watibot/modules/home/repositories/home_repository.dart';
import 'package:watibot/modules/more/views/profile_detail_view.dart';

class MoreController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final HomeRepository _homeRepo = Get.find<HomeRepository>();

  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userRole = ''.obs;

  final RxString userAvatar = ''.obs;

  final RxString workspaceName = 'Loading...'.obs;
  final RxString workspacePlan = ''.obs;
  final RxString workspaceLogo = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Load local user data
    userName.value = _storage.userName ?? 'User';
    userEmail.value = _storage.userEmail ?? '';
    userRole.value = _storage.userRole ?? 'Member';
    userAvatar.value = _storage.userAvatar ?? '';

    // Fetch workspace data from API
    try {
      final status = await _homeRepo.getWorkspaceStatus();
      workspaceName.value = status.name;
      workspacePlan.value = status.plan.capitalizeFirst ?? status.plan;
      workspaceLogo.value = status.logo ?? '';
    } catch (e) {
      workspaceName.value = 'Workspace';
      Get.snackbar('Error', 'Failed to load workspace details');
    }
  }

  void openProfileDetails() {
    Get.to(() => const ProfileDetailView());
  }
}
