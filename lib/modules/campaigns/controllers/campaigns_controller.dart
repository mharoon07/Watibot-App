import 'package:get/get.dart';
import 'package:watibot/modules/campaigns/models/campaign_model.dart';
import 'package:watibot/modules/campaigns/repositories/campaigns_repository.dart';

class CampaignsController extends GetxController {
  final CampaignsRepository _repository;

  CampaignsController(this._repository);

  final campaigns = <CampaignModel>[].obs;
  final filteredCampaigns = <CampaignModel>[].obs;
  
  final loading = true.obs;
  final selectedTab = 0.obs;
  final searchQuery = ''.obs;

  final tabs = [
    'All',
    'Active',
    'Scheduled',
    'Drafts',
    'Running',
    'Paused',
    'Completed',
    'Archived',
  ];

  @override
  void onInit() {
    super.onInit();
    loadCampaigns();

    // Debounce search
    debounce(searchQuery, (_) => filterCampaigns(), time: const Duration(milliseconds: 300));
  }

  Future<void> loadCampaigns() async {
    loading.value = true;
    try {
      final data = await _repository.getCampaigns();
      campaigns.assignAll(data);
      filterCampaigns();
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshCampaigns() async {
    await loadCampaigns();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    filterCampaigns();
  }

  void searchCampaign(String query) {
    searchQuery.value = query;
  }

  void filterCampaigns() {
    var result = campaigns.toList();

    // 1. Search Filter
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) || 
               c.type.toLowerCase().contains(q) ||
               c.owner.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Tab Filter
    final tabName = tabs[selectedTab.value];
    switch (tabName) {
      case 'Active':
        result = result.where((c) => c.status == CampaignStatus.sending || c.status == CampaignStatus.running).toList();
        break;
      case 'Scheduled':
        result = result.where((c) => c.status == CampaignStatus.scheduled).toList();
        break;
      case 'Drafts':
        result = result.where((c) => c.status == CampaignStatus.draft).toList();
        break;
      case 'Running':
        result = result.where((c) => c.status == CampaignStatus.running).toList();
        break;
      case 'Paused':
        result = result.where((c) => c.status == CampaignStatus.paused).toList();
        break;
      case 'Completed':
        result = result.where((c) => c.status == CampaignStatus.completed).toList();
        break;
      case 'Archived':
        result = result.where((c) => c.status == CampaignStatus.archived).toList();
        break;
      case 'All':
      default:
        // Do not show archived in "All" unless explicitly selected
        result = result.where((c) => c.status != CampaignStatus.archived).toList();
        break;
    }

    // Sort by createdAt descending
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    filteredCampaigns.assignAll(result);
  }

  void pauseCampaign(String id) {
    _updateStatus(id, CampaignStatus.paused);
  }

  void resumeCampaign(String id) {
    _updateStatus(id, CampaignStatus.running);
  }

  void duplicateCampaign(String id) {
    final existing = campaigns.firstWhereOrNull((c) => c.id == id);
    if (existing != null) {
      final newCampaign = CampaignModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${existing.name} (Copy)',
        type: existing.type,
        status: CampaignStatus.draft,
        createdAt: DateTime.now(),
        audienceCount: existing.audienceCount,
        owner: existing.owner,
      );
      campaigns.insert(0, newCampaign);
      filterCampaigns();
      Get.snackbar('Duplicated', '${existing.name} was duplicated successfully.');
    }
  }

  void archiveCampaign(String id) {
    _updateStatus(id, CampaignStatus.archived);
    Get.snackbar('Archived', 'Campaign moved to archive.');
  }

  void deleteCampaign(String id) {
    campaigns.removeWhere((c) => c.id == id);
    filterCampaigns();
    Get.snackbar('Deleted', 'Campaign deleted permanently.');
  }

  void createCampaign() {
    Get.snackbar('Coming Soon', 'Campaign builder will open here.');
  }

  void _updateStatus(String id, CampaignStatus newStatus) {
    final index = campaigns.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = campaigns[index];
      campaigns[index] = CampaignModel(
        id: old.id,
        name: old.name,
        type: old.type,
        status: newStatus,
        createdAt: old.createdAt,
        audienceCount: old.audienceCount,
        owner: old.owner,
        messagesSent: old.messagesSent,
        deliveryRate: old.deliveryRate,
        openRate: old.openRate,
        clickRate: old.clickRate,
        replyRate: old.replyRate,
        deliveryProgress: old.deliveryProgress,
      );
      filterCampaigns();
    }
  }
}
