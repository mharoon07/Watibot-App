import 'package:get/get.dart';
import 'package:watibot/modules/agents/models/agent_model.dart';
import 'package:watibot/modules/agents/repositories/agents_repository.dart';

class AgentsController extends GetxController {
  final AgentsRepository _repository = AgentsRepository();

  final RxList<AgentModel> agents = <AgentModel>[].obs;
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  final RxList<PermissionModuleModel> permissionModules = <PermissionModuleModel>[].obs;
  final RxMap<String, dynamic> roleCounts = <String, dynamic>{}.obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;

  final RxString selectedRoleFilter = 'ALL'.obs;
  final RxString selectedStatusFilter = 'ALL'.obs;
  final RxString selectedDepartmentId = 'ALL'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    await Future.wait([
      fetchAgents(),
      fetchPermissionsMeta(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchAgents() async {
    final res = await _repository.getAgents(
      search: searchQuery.value,
      role: selectedRoleFilter.value == 'ALL' ? '' : selectedRoleFilter.value,
      status: selectedStatusFilter.value == 'ALL' ? '' : selectedStatusFilter.value,
      departmentId: selectedDepartmentId.value == 'ALL' ? '' : selectedDepartmentId.value,
    );

    if (res['success'] == true) {
      agents.value = List<AgentModel>.from(res['agents']);
      if (res['departments'] != null) {
        departments.value = List<DepartmentModel>.from(res['departments']);
      }
    }
  }

  Future<void> fetchPermissionsMeta() async {
    final res = await _repository.getPermissionsMeta();
    if (res['success'] == true) {
      permissionModules.value = List<PermissionModuleModel>.from(res['modules']);
      roleCounts.value = Map<String, dynamic>.from(res['role_counts']);
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchAgents();
  }

  void onRoleFilterChanged(String role) {
    selectedRoleFilter.value = role;
    fetchAgents();
  }

  void onStatusFilterChanged(String status) {
    selectedStatusFilter.value = status;
    fetchAgents();
  }

  void onDepartmentFilterChanged(String deptId) {
    selectedDepartmentId.value = deptId;
    fetchAgents();
  }

  Future<bool> createAgent({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'USER',
    String status = 'ACTIVE',
    String? departmentId,
    Map<String, dynamic>? permissions,
  }) async {
    isSaving.value = true;
    final payload = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      if (phone?.trim().isNotEmpty == true) 'phone_number': phone!.trim(),
      'role': role,
      'status': status,
      if (departmentId != null && departmentId.isNotEmpty && departmentId != 'ALL') 'department_id': departmentId,
      if (permissions != null) 'permissions': permissions,
    };


    final res = await _repository.createAgent(payload);
    isSaving.value = false;

    if (res['success'] == true) {
      Get.snackbar('Success', 'Agent created successfully', snackPosition: SnackPosition.BOTTOM);
      fetchAgents();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to create agent', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> updateAgent(
    String id, {
    String? name,
    String? email,
    String? password,
    String? phone,
    String? role,
    String? status,
    String? departmentId,
    Map<String, dynamic>? permissions,
  }) async {
    isSaving.value = true;
    final payload = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (email != null) 'email': email.trim().toLowerCase(),
      if (password != null && password.isNotEmpty) 'password': password,
      if (phone != null) 'phone_number': phone.trim(),
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (departmentId != null) 'department_id': departmentId == 'ALL' ? '' : departmentId,
      if (permissions != null) 'permissions': permissions,
    };

    final res = await _repository.updateAgent(id, payload);
    isSaving.value = false;

    if (res['success'] == true) {
      Get.snackbar('Success', 'Agent updated successfully', snackPosition: SnackPosition.BOTTOM);
      fetchAgents();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to update agent', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> deleteAgent(String id) async {
    final res = await _repository.deleteAgent(id);
    if (res['success'] == true) {
      Get.snackbar('Success', 'Agent deleted successfully', snackPosition: SnackPosition.BOTTOM);
      fetchAgents();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to delete agent', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
