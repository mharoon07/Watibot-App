import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:watibot/modules/notifications/controllers/notifications_controller.dart';
import 'package:watibot/modules/notifications/models/notification_model.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              if (controller.unreadCount.value == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${controller.unreadCount.value}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: Text(
              'Mark All Read',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00B074),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchNotifications,
        color: const Color(0xFF00B074),
        child: CustomScrollView(
          slivers: [
            // Filter Tabs Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabChip('all', 'All Activity'),
                      const SizedBox(width: 8),
                      _buildTabChip('messages', 'Messages'),
                      const SizedBox(width: 8),
                      _buildTabChip('contacts', 'Contacts'),
                      const SizedBox(width: 8),
                      _buildTabChip('campaigns', 'Campaigns'),
                      const SizedBox(width: 8),
                      _buildTabChip('flows', 'Flows & Bots'),
                      const SizedBox(width: 8),
                      _buildTabChip('system', 'System & Team'),
                    ],
                  ),
                )),
              ),
            ),

            // Notifications List
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B074)),
                  ),
                );
              }

              if (controller.notifications.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none_outlined, size: 54, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          'No Notifications Yet',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Activity logs and system alerts will appear here',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = controller.notifications[index];
                      return _buildNotificationCard(item);
                    },
                    childCount: controller.notifications.length,
                  ),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String key, String label) {
    final isSelected = controller.selectedTab.value == key;
    return InkWell(
      onTap: () => controller.onTabChanged(key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B074).withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF00B074) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF00B074) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItemModel item) {
    final theme = _getModuleTheme(item.module);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : theme['bgColor'] as Color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.isRead ? const Color(0xFFE2E8F0) : (theme['color'] as Color).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.markAsRead(item.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module Icon Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: (theme['color'] as Color).withValues(alpha: 0.12),
                child: Icon(theme['icon'] as IconData, color: theme['color'] as Color, size: 20),
              ),
              const SizedBox(width: 14),

              // Content Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.userName ?? item.userEmail ?? 'System',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.action.replaceAll('_', ' ').capitalizeFirst ?? item.action} ${item.target != null ? "· ${item.target}" : ""}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),

                    if (item.details != null && item.details!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.details!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      item.createdAt != null
                          ? DateFormat('MMM dd, yyyy · hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(item.createdAt!))
                          : 'Just now',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getModuleTheme(String module) {
    final mod = module.toLowerCase();
    if (mod.contains('message') || mod.contains('whatsapp') || mod.contains('chat')) {
      return {'icon': Icons.chat_bubble_outline, 'color': const Color(0xFF00B074), 'bgColor': const Color(0xFFECFDF5)};
    } else if (mod.contains('campaign')) {
      return {'icon': Icons.campaign_outlined, 'color': const Color(0xFF8B5CF6), 'bgColor': const Color(0xFFF5F3FF)};
    } else if (mod.contains('contact')) {
      return {'icon': Icons.person_outline, 'color': const Color(0xFF3B82F6), 'bgColor': const Color(0xFFEFF6FF)};
    } else if (mod.contains('flow') || mod.contains('automation')) {
      return {'icon': Icons.account_tree_outlined, 'color': const Color(0xFFEC4899), 'bgColor': const Color(0xFFFDF2F8)};
    } else {
      return {'icon': Icons.notifications_none_outlined, 'color': const Color(0xFFF59E0B), 'bgColor': const Color(0xFFFFFBEB)};
    }
  }
}
