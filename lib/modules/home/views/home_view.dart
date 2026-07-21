import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/home/controllers/home_controller.dart';
import 'package:watibot/modules/home/widgets/dashboard_header.dart';
import 'package:watibot/modules/home/widgets/chart_card.dart';
import 'package:watibot/modules/home/widgets/stats_card.dart';
import 'package:watibot/modules/home/widgets/activity_tile.dart';
import 'package:watibot/modules/home/widgets/dashboard_bottom_nav.dart';
import 'package:watibot/modules/home/widgets/recent_activity_card.dart';
import 'package:watibot/modules/home/widgets/workspace_overview_card.dart';
import 'package:watibot/modules/inbox/views/inbox_view.dart';
import 'package:watibot/modules/campaigns/views/campaigns_view.dart';
import 'package:watibot/modules/contacts/views/contacts_view.dart';
import 'package:watibot/modules/more/views/more_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Obx(() => IndexedStack(
            index: controller.selectedTab.value,
            children: [
              SafeArea(
                bottom: false,
                child: _buildDashboardContent(),
              ),
              const InboxView(),
              const CampaignsView(),
              const ContactsView(),
              const MoreView(),
            ],
          )),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(
              () => DashboardBottomNav(
                selectedIndex: controller.selectedTab.value,
                onItemSelected: controller.changeTab,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Obx(() {
      if (controller.loading.value) {
        return _buildSkeleton();
      }

      final stats = controller.dashboardStats.value;
      final workspace = controller.workspaceStatus.value;
      final usage = controller.usageOverview.value;
      final activities = controller.recentActivities.value;

      if (stats == null) {
        return const Center(child: Text('No Data Available'));
      }

      final statCards = [
        {'title': 'Total Conversations', 'value': '${stats.liveChats}', 'trend': 18.6, 'icon': 'forum'},
        {'title': 'Active Contacts', 'value': '${stats.activeContacts}', 'trend': 14.2, 'icon': 'people'},
        {'title': 'Campaign Sent', 'value': '${stats.campaignsSent}', 'trend': 22.5, 'icon': 'rocket_launch'},
        {'title': 'Active Flows', 'value': '${stats.totalFlows}', 'trend': 8.4, 'icon': 'account_tree'},
      ];

      return RefreshIndicator(
        onRefresh: controller.refreshDashboard,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Obx(() => DashboardHeader(
                onNotificationTap: controller.openNotifications,
                onProfileTap: controller.openProfile,
                userName: controller.accountEmail.value.isNotEmpty 
                    ? controller.accountEmail.value 
                    : controller.userName.value,
                userAvatar: controller.userAvatar.value,
              )),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: ChartCard(data: stats),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = statCards[index];
                    return StatsCard(
                      title: item['title'] as String,
                      value: item['value'] as String,
                      trend: item['trend'] as double,
                      iconCode: item['icon'] as String,
                      index: index,
                    );
                  },
                  childCount: statCards.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: WorkspaceOverviewCard(
                workspaceStatus: workspace,
                usageOverview: usage,
              ),
            ),
            SliverToBoxAdapter(
              child: RecentActivityCard(activities: activities),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      );
    });
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        Row(
          children: [
            Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 12, color: const Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                Container(width: 150, height: 18, color: const Color(0xFFE2E8F0)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(width: double.infinity, height: 160, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(24))),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Container(height: 100, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(16)))),
            const SizedBox(width: 12),
            Expanded(child: Container(height: 100, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(16)))),
          ],
        ),
      ],
    );
  }
}
