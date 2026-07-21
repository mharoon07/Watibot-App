import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/home/models/recent_activity_model.dart';
import 'package:watibot/modules/home/repositories/home_repository.dart';

class ActivityLogController extends GetxController {
  final HomeRepository _repository = Get.find<HomeRepository>();
  
  final RxList<RecentActivityModel> activities = <RecentActivityModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  
  final ScrollController scrollController = ScrollController();
  
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadInitialData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMoreData();
    }
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    hasError.value = false;
    _currentPage = 1;
    
    try {
      final data = await _repository.getPaginatedActivities(page: _currentPage, limit: 20);
      activities.value = data['logs'] as List<RecentActivityModel>;
      _totalPages = data['totalPages'] as int;
    } catch (e) {
      print('Error loading activity logs: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreData() async {
    if (isLoadingMore.value || _currentPage >= _totalPages) return;
    
    isLoadingMore.value = true;
    _currentPage++;
    
    try {
      final data = await _repository.getPaginatedActivities(page: _currentPage, limit: 20);
      activities.addAll(data['logs'] as List<RecentActivityModel>);
    } catch (e) {
      print('Error loading more activity logs: $e');
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }
}
