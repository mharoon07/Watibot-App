import 'package:get/get.dart';
import 'package:watibot/modules/audience/models/audience_model.dart';
import 'package:watibot/modules/audience/repositories/audience_repository.dart';

class AudienceController extends GetxController {
  final AudienceRepository _repository = AudienceRepository();

  final Rxn<AudienceSummaryModel> summary = Rxn<AudienceSummaryModel>();
  final RxList<AudienceSegmentModel> segments = <AudienceSegmentModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedTypeFilter = 'ALL'.obs; // 'ALL', 'TAG', 'GROUP'

  @override
  void onInit() {
    super.onInit();
    fetchAudienceData();
  }

  Future<void> fetchAudienceData() async {
    isLoading.value = true;
    final res = await _repository.getAudienceData();
    isLoading.value = false;

    if (res['success'] == true) {
      summary.value = res['audience'] as AudienceSummaryModel?;
      segments.value = List<AudienceSegmentModel>.from(res['segments']);
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to load audience data', snackPosition: SnackPosition.BOTTOM);
    }
  }

  List<AudienceSegmentModel> get filteredSegments {
    return segments.where((s) {
      final matchesType = selectedTypeFilter.value == 'ALL' ||
          (selectedTypeFilter.value == 'TAG' && s.isTag) ||
          (selectedTypeFilter.value == 'GROUP' && s.isGroup);

      final query = searchQuery.value.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          s.title.toLowerCase().contains(query) ||
          (s.category?.toLowerCase().contains(query) ?? false) ||
          (s.description?.toLowerCase().contains(query) ?? false);

      return matchesType && matchesQuery;
    }).toList();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void onTypeFilterChanged(String type) {
    selectedTypeFilter.value = type;
  }

  Future<bool> createTagSegment({
    required String name,
    String color = '#10B981',
    String category = 'General',
  }) async {
    isSaving.value = true;
    final res = await _repository.createTag(name: name, color: color, category: category);
    isSaving.value = false;

    if (res['success'] == true) {
      Get.snackbar('Success', 'Audience tag segment created', snackPosition: SnackPosition.BOTTOM);
      fetchAudienceData();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to create tag segment', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> deleteSegment(String tagId) async {
    final res = await _repository.deleteTag(tagId);
    if (res['success'] == true) {
      Get.snackbar('Success', 'Audience segment deleted', snackPosition: SnackPosition.BOTTOM);
      fetchAudienceData();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to delete segment', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
