import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/core/services/storage_service.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';

class InboxController extends GetxController {
  final InboxRepository _repository;
  final _storage = Get.find<StorageService>();

  String get userAvatar => _storage.userAvatar ?? '';

  InboxController(this._repository);

  final conversations = <ConversationModel>[].obs;
  final filteredConversations = <ConversationModel>[].obs;
  
  final activeFilter = 'All'.obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final searchQuery = ''.obs;
  final lastError = ''.obs;

  final scrollController = ScrollController();

  int _currentPage = 1;
  bool _hasMore = true;
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    
    // Setup debounce for search
    debounce(searchQuery, (_) {
      _currentPage = 1;
      fetchConversations();
    }, time: const Duration(milliseconds: 300));

    scrollController.addListener(_onScroll);
    
    // Start silent polling every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      pollConversations();
    });
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadNextPage();
    }
  }

  Future<void> fetchConversations() async {
    _currentPage = 1;
    isLoading.value = true;
    try {
      final tabMap = {
        'All': 'all',
        'Unread': 'unread',
        'Assigned Chat': 'assigned',
        'AI Chat': 'ai',
        'Intervented Chat': 'intervented',
      };
      
      final currentTab = tabMap[activeFilter.value] ?? 'all';
      final requesterId = _storage.userId;
      final requesterEmail = _storage.userEmail;

      final data = await _repository.getPaginatedConversations(
        page: _currentPage,
        search: searchQuery.value,
        tab: currentTab,
        requesterId: requesterId,
        requesterEmail: requesterEmail,
      );
      
      // Prevent race conditions: discard data if the tab changed during the request
      if ((tabMap[activeFilter.value] ?? 'all') != currentTab) {
        return;
      }

      conversations.assignAll(data['conversations'] as List<ConversationModel>);
      filterChats();
      _hasMore = data['hasMore'] as bool;
      debugPrint('Fetched ${conversations.length} conversations');
    } catch (e, stack) {
      lastError.value = e.toString();
      debugPrint('Error fetching conversations: $e');
      debugPrint('Stacktrace: $stack');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pollConversations() async {
    try {
      final tabMap = {
        'All': 'all',
        'Unread': 'unread',
        'Assigned Chat': 'assigned',
        'AI Chat': 'ai',
        'Intervented Chat': 'intervented',
      };
      
      final currentTab = tabMap[activeFilter.value] ?? 'all';
      final requesterId = _storage.userId;
      final requesterEmail = _storage.userEmail;

      final data = await _repository.getPaginatedConversations(
        page: 1,
        search: searchQuery.value,
        tab: currentTab,
        requesterId: requesterId,
        requesterEmail: requesterEmail,
      );

      // Prevent race conditions: discard data if the tab changed during the request
      if ((tabMap[activeFilter.value] ?? 'all') != currentTab) {
        return;
      }
      
      final newConvos = data['conversations'] as List<ConversationModel>;
      bool changed = false;
      
      for (var newConv in newConvos) {
        final index = conversations.indexWhere((c) => c.id == newConv.id);
        if (index != -1) {
          if (conversations[index].unreadCount != newConv.unreadCount ||
              conversations[index].lastMessage != newConv.lastMessage ||
              conversations[index].isPinned != newConv.isPinned) {
            conversations[index] = newConv;
            changed = true;
          }
        } else {
          conversations.insert(0, newConv);
          changed = true;
        }
      }
      
      if (changed) {
        filterChats();
      }
    } catch (e) {
      debugPrint('Silent poll failed: $e');
    }
  }

  Future<void> loadNextPage() async {
    if (isLoadingMore.value || !_hasMore || isLoading.value) return;

    isLoadingMore.value = true;
    try {
      _currentPage++;
      final tabMap = {
        'All': 'all',
        'Unread': 'unread',
        'Assigned Chat': 'assigned',
        'AI Chat': 'ai',
        'Intervented Chat': 'intervented',
      };
      
      final currentTab = tabMap[activeFilter.value] ?? 'all';
      final requesterId = _storage.userId;
      final requesterEmail = _storage.userEmail;

      final data = await _repository.getPaginatedConversations(
        page: _currentPage,
        search: searchQuery.value,
        tab: currentTab,
        requesterId: requesterId,
        requesterEmail: requesterEmail,
      );

      // Prevent race conditions: discard data if the tab changed during the request
      if ((tabMap[activeFilter.value] ?? 'all') != currentTab) {
        _currentPage--; // Revert page increment
        return;
      }
      
      final newConvos = data['conversations'] as List<ConversationModel>;
      _hasMore = data['hasMore'] as bool;

      // Prevent duplicates
      for (var conv in newConvos) {
        if (!conversations.any((c) => c.id == conv.id)) {
          conversations.add(conv);
        }
      }
      filterChats();
    } catch (e, stack) {
      _currentPage--; // Revert page on failure
      debugPrint('Error fetching next page: $e');
      debugPrint('Stacktrace: $stack');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void setActiveFilter(String filter) {
    if (activeFilter.value == filter) return; // Ignore if same filter tapped
    activeFilter.value = filter;
    fetchConversations(); // Trigger a new API fetch from page 1
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void filterChats() {
    var result = conversations.toList();
    // Sort: Pinned first, then by timestamp
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.lastMessageAt.compareTo(a.lastMessageAt);
    });
    filteredConversations.assignAll(result);
  }

  Future<void> refreshInbox() async {
    await fetchConversations();
  }

  void archiveChat(String id) {
    conversations.removeWhere((c) => c.id == id);
    filterChats();
  }

  void markAsRead(String id) {
    final index = conversations.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = conversations[index];
      conversations[index] = ConversationModel(
        id: old.id,
        customerName: old.customerName,
        customerAvatar: old.customerAvatar,
        customerPhone: old.customerPhone,
        lastMessage: old.lastMessage,
        lastMessageAt: old.lastMessageAt,
        unreadCount: 0,
        isOnline: old.isOnline,
        isPinned: old.isPinned,
        handledByAi: old.handledByAi,
        priority: old.priority,
        isVerified: old.isVerified,
        assignedAgent: old.assignedAgent,
      );
      filterChats();
    }
  }

  void pinChat(String id) {
    final index = conversations.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = conversations[index];
      conversations[index] = ConversationModel(
        id: old.id,
        customerName: old.customerName,
        customerAvatar: old.customerAvatar,
        customerPhone: old.customerPhone,
        lastMessage: old.lastMessage,
        lastMessageAt: old.lastMessageAt,
        unreadCount: old.unreadCount,
        isOnline: old.isOnline,
        isPinned: !old.isPinned,
        handledByAi: old.handledByAi,
        priority: old.priority,
        isVerified: old.isVerified,
        assignedAgent: old.assignedAgent,
      );
      filterChats();
    }
  }
}
