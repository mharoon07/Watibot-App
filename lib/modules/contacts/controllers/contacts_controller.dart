import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/contacts/models/contact_model.dart';
import 'package:watibot/modules/contacts/repositories/contacts_repository.dart';
import 'package:watibot/modules/home/controllers/home_controller.dart';

class ContactsController extends GetxController {
  final ContactsRepository _repository = Get.find<ContactsRepository>();
  
  final RxList<ContactModel> contacts = <ContactModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  
  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'All'.obs;
  final List<String> tabs = ['All', 'Recent', 'Favorites', 'Customers'];
  
  final RxInt totalContacts = 0.obs;
  final RxInt activeToday = 0.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
    _loadStats();
    loadInitialData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void _loadStats() {
    try {
      final homeController = Get.find<HomeController>();
      if (homeController.dashboardStats.value != null) {
        activeToday.value = homeController.dashboardStats.value!.activeContacts;
      }
    } catch (e) {
      // HomeController might not be initialized if accessed directly
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMoreData();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchQuery.value != searchController.text) {
        searchQuery.value = searchController.text;
        loadInitialData();
      }
    });
  }

  void setTab(String tab) {
    if (selectedTab.value != tab) {
      selectedTab.value = tab;
      loadInitialData();
    }
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    hasError.value = false;
    _currentPage = 1;
    
    try {
      final data = await _repository.getPaginatedContacts(
        page: _currentPage, 
        limit: 20,
        search: searchQuery.value,
        tab: selectedTab.value.toLowerCase(),
      );
      contacts.value = data['contacts'] as List<ContactModel>;
      _totalPages = data['totalPages'] as int;
      totalContacts.value = data['total'] as int;
    } catch (e) {
      print('Error loading contacts: $e');
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
      final data = await _repository.getPaginatedContacts(
        page: _currentPage, 
        limit: 20,
        search: searchQuery.value,
        tab: selectedTab.value.toLowerCase(),
      );
      contacts.addAll(data['contacts'] as List<ContactModel>);
    } catch (e) {
      print('Error loading more contacts: $e');
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }
}
