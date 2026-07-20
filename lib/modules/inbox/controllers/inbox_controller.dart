import 'package:get/get.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';

class InboxController extends GetxController {
  final InboxRepository _repository;

  InboxController(this._repository);

  final conversations = <ConversationModel>[].obs;
  final filteredConversations = <ConversationModel>[].obs;
  
  final activeFilter = 'All'.obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    
    // Setup debounce for search
    debounce(searchQuery, (_) => filterChats(), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    try {
      final data = await _repository.getConversations();
      conversations.assignAll(data);
      filterChats();
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    activeFilter.value = filter;
    filterChats();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void filterChats() {
    var result = conversations.toList();

    // 1. Apply Search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((c) {
        return c.customerName.toLowerCase().contains(query) ||
               c.lastMessage.content.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Apply Filter Chip
    switch (activeFilter.value) {
      case 'Unread':
        result = result.where((c) => c.unreadCount > 0).toList();
        break;
      case 'Handled by AI':
        result = result.where((c) => c.handledByAi).toList();
        break;
      case 'Assigned To Me':
        result = result.where((c) => c.assignedAgent == 'Michael').toList(); // Assuming current user is Michael
        break;
      case 'Starred':
        result = result.where((c) => c.isPinned).toList();
        break;
      case 'High Priority':
        result = result.where((c) => c.priority == 'high').toList();
        break;
    }

    // Sort: Pinned first, then by timestamp
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp);
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
