import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/core/services/chat_cache_service.dart';
import 'package:watibot/core/services/storage_service.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';

class InboxController extends GetxController {
  final InboxRepository _repository;
  final _storage = Get.find<StorageService>();
  final _cacheService = Get.find<ChatCacheService>();

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
    
    // Load cached conversations instantly (0ms load time)
    final cachedList = _cacheService.getCachedConversations();
    if (cachedList.isNotEmpty) {
      conversations.assignAll(cachedList);
      filterChats();
      isLoading.value = false;
    }

    // Fetch latest conversations from CRM in background
    fetchConversations(silent: cachedList.isNotEmpty);
    
    // Setup debounce for network search
    debounce(searchQuery, (_) {
      _currentPage = 1;
      fetchConversations(silent: conversations.isNotEmpty);
    }, time: const Duration(milliseconds: 300));

    scrollController.addListener(_onScroll);
    
    // Fast silent polling every 6 seconds for real-time CRM updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 6), (_) {
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

  Future<void> fetchConversations({bool silent = false}) async {
    _currentPage = 1;
    if (!silent && conversations.isEmpty) {
      isLoading.value = true;
    }
    
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
      
      // Prevent race conditions: discard data if tab changed during request
      if ((tabMap[activeFilter.value] ?? 'all') != currentTab) {
        return;
      }

      final fetchedList = data['conversations'] as List<ConversationModel>;
      conversations.assignAll(fetchedList);
      filterChats();
      _hasMore = data['hasMore'] as bool;
      lastError.value = '';

      // Persist to local cache if standard tab and search
      if (activeFilter.value == 'All' && searchQuery.value.isEmpty) {
        _cacheService.saveConversations(fetchedList);
      }
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

      if ((tabMap[activeFilter.value] ?? 'all') != currentTab) {
        return;
      }
      
      final newConvos = data['conversations'] as List<ConversationModel>;
      bool changed = false;
      
      for (var newConv in newConvos) {
        final index = conversations.indexWhere((c) => c.id == newConv.id);
        if (index != -1) {
          final existing = conversations[index];
          if (existing.unreadCount != newConv.unreadCount ||
              existing.lastMessage?.id != newConv.lastMessage?.id ||
              existing.lastMessage?.content != newConv.lastMessage?.content ||
              existing.lastMessage?.status != newConv.lastMessage?.status ||
              existing.isPinned != newConv.isPinned) {
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
        if (activeFilter.value == 'All' && searchQuery.value.isEmpty) {
          _cacheService.saveConversations(conversations.toList());
        }
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

      if ((tabMap[activeFilter.value] ?? 'all') != currentTab) {
        _currentPage--;
        return;
      }
      
      final newConvos = data['conversations'] as List<ConversationModel>;
      _hasMore = data['hasMore'] as bool;

      for (var conv in newConvos) {
        if (!conversations.any((c) => c.id == conv.id)) {
          conversations.add(conv);
        }
      }
      filterChats();
    } catch (e, stack) {
      _currentPage--;
      debugPrint('Error fetching next page: $e');
      debugPrint('Stacktrace: $stack');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void setActiveFilter(String filter) {
    if (activeFilter.value == filter) return;
    activeFilter.value = filter;
    fetchConversations(silent: conversations.isNotEmpty);
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterChats(); // Instant local search
  }

  void filterChats() {
    var result = conversations.toList();

    // Perform instant local text search if query provided
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((c) {
        final nameMatch = c.customerName.toLowerCase().contains(query);
        final phoneMatch = c.customerPhone.toLowerCase().contains(query);
        final messageMatch = c.lastMessage?.content.toLowerCase().contains(query) ?? false;
        return nameMatch || phoneMatch || messageMatch;
      }).toList();
    }

    // Sort: Pinned first, then by latest timestamp descending
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
