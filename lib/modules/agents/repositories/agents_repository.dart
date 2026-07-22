import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/agents/models/agent_model.dart';

class AgentsRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> getAgents({
    int page = 1,
    int limit = 50,
    String search = '',
    String status = '',
    String role = '',
    String departmentId = '',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (status.trim().isNotEmpty) 'status': status.trim(),
        if (role.trim().isNotEmpty) 'role': role.trim(),
        if (departmentId.trim().isNotEmpty) 'department_id': departmentId.trim(),
      };

      final response = await _apiService.get('/agents', queryParameters: queryParams);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final agentsList = (data['agents'] as List<dynamic>?)
                ?.map((e) => AgentModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        final deptsList = (data['departments'] as List<dynamic>?)
                ?.map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        return {
          'success': true,
          'total': data['total'] ?? agentsList.length,
          'agents': agentsList,
          'departments': deptsList,
        };
      }
      return {'success': false, 'agents': <AgentModel>[], 'departments': <DepartmentModel>[], 'total': 0};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to fetch agents'), 'agents': <AgentModel>[], 'departments': <DepartmentModel>[], 'total': 0};
    }
  }

  Future<Map<String, dynamic>> getPermissionsMeta() async {
    try {
      final response = await _apiService.get('/permissions');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final modules = (data['modules'] as List<dynamic>?)
                ?.map((e) => PermissionModuleModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        final roleCounts = data['role_counts'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(data['role_counts'])
            : <String, dynamic>{};

        return {
          'success': true,
          'modules': modules,
          'role_counts': roleCounts,
        };
      }
      return {'success': false, 'modules': <PermissionModuleModel>[]};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to fetch permissions'), 'modules': <PermissionModuleModel>[]};
    }
  }

  Future<Map<String, dynamic>> createAgent(Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.post('/agents', data: payload);
      final data = response.data;
      if (data is Map<String, dynamic> && data['agent'] != null) {
        return {'success': true, 'agent': AgentModel.fromJson(data['agent'])};
      }
      return {'success': true, 'message': 'Agent created'};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to create agent')};
    }
  }

  Future<Map<String, dynamic>> updateAgent(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.patch('/agents/$id', data: payload);
      final data = response.data;
      if (data is Map<String, dynamic> && data['agent'] != null) {
        return {'success': true, 'agent': AgentModel.fromJson(data['agent'])};
      }
      return {'success': true, 'message': 'Agent updated'};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to update agent')};
    }
  }

  Future<Map<String, dynamic>> deleteAgent(String id) async {
    try {
      final response = await _apiService.delete('/agents/$id');
      final data = response.data;
      return {'success': data['success'] ?? true};
    } catch (e) {
      return {'success': false, 'error': ApiService.extractErrorMessage(e, 'Failed to delete agent')};
    }
  }

}
