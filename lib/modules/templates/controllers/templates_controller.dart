import 'package:get/get.dart';
import 'package:watibot/modules/templates/models/template_model.dart';
import 'package:watibot/modules/templates/repositories/templates_repository.dart';

class TemplatesController extends GetxController {
  final TemplatesRepository _repository = TemplatesRepository();


  final RxList<TemplateModel> templates = <TemplateModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isCreating = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter and Search State
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'ALL'.obs; // ALL, MARKETING, UTILITY, AUTHENTICATION
  final RxString selectedStatus = 'ALL'.obs; // ALL, APPROVED, PENDING, REJECTED

  // Details and variable testing
  final Rx<TemplateModel?> selectedTemplate = Rx<TemplateModel?>(null);
  final RxMap<String, String> detailTestValues = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getTemplates(
        search: searchQuery.value,
        category: selectedCategory.value,
        status: selectedStatus.value,
      );

      final List<TemplateModel> list = result['templates'] ?? [];
      templates.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
      templates.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchTemplates();
  }

  void onCategorySelected(String category) {
    selectedCategory.value = category;
    fetchTemplates();
  }

  void onStatusSelected(String status) {
    selectedStatus.value = status;
    fetchTemplates();
  }

  void openTemplateDetails(TemplateModel template) {
    selectedTemplate.value = template;
    detailTestValues.clear();
  }

  void setTestValue(String key, String value) {
    detailTestValues[key] = value;
  }

  void clearTestValues() {
    detailTestValues.clear();
  }

  int get approvedCount => templates.where((t) => t.status == 'APPROVED').length;
  int get pendingCount => templates.where((t) => t.status == 'PENDING').length;
  int get rejectedCount => templates.where((t) => t.status == 'REJECTED' || t.status == 'FAILED').length;

  List<TemplateModel> get filteredTemplates {
    return templates.where((t) {
      final matchesSearch = searchQuery.value.isEmpty ||
          t.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (t.text ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesCategory = selectedCategory.value == 'ALL' || t.category == selectedCategory.value;
      final matchesStatus = selectedStatus.value == 'ALL' || t.status == selectedStatus.value;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Future<void> createTemplate(Map<String, dynamic> payload) async {
    try {
      isCreating.value = true;
      final newTemplate = await _repository.createTemplate(payload);
      templates.insert(0, newTemplate);
    } catch (e) {
      rethrow;
    } finally {
      isCreating.value = false;
    }
  }
}

