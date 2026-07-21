import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/inbox/controllers/inbox_controller.dart';
import 'package:watibot/modules/inbox/widgets/filter_chip_list.dart';
import 'package:watibot/modules/inbox/widgets/conversation_tile.dart';

class InboxView extends GetView<InboxController> {
  const InboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 12),
          FilterChipList(),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }

              if (controller.filteredConversations.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshInbox,
                color: AppTheme.primaryColor,
                child: ListView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.filteredConversations.length + (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.filteredConversations.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                      );
                    }
                    final conv = controller.filteredConversations[index];
                    return ConversationTile(
                      conversation: conv,
                      onArchive: () => controller.archiveChat(conv.id),
                      onPin: () => controller.pinChat(conv.id),
                      onMarkRead: () => controller.markAsRead(conv.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: const Color(0xFFE2E8F0),
          backgroundImage: controller.userAvatar.isNotEmpty 
              ? NetworkImage(controller.userAvatar) 
              : null,
          child: controller.userAvatar.isEmpty 
              ? const Icon(Icons.person, color: Color(0xFF94A3B8))
              : null,
        ),
      ),
      title: Text(
        'Inbox',
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF475569)),
          onPressed: () {
            Get.toNamed('/notifications');
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(22),
        ),
        child: TextField(
          onChanged: controller.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 15,
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: const Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          Text(
            'No conversations found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.lastError.value.isNotEmpty ? controller.lastError.value : 'Try adjusting your filters or search query.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: controller.lastError.value.isNotEmpty ? Colors.red.shade400 : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
