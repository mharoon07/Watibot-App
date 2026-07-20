import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/home/controllers/home_controller.dart';
import 'package:watibot/modules/home/widgets/dashboard_header.dart';
import 'package:watibot/modules/home/widgets/chart_card.dart';
import 'package:watibot/modules/home/widgets/stats_card.dart';
import 'package:watibot/modules/home/widgets/activity_tile.dart';
import 'package:watibot/modules/home/widgets/dashboard_section.dart';
import 'package:watibot/modules/home/widgets/dashboard_bottom_nav.dart';
import 'package:watibot/modules/inbox/views/inbox_view.dart';
import 'package:watibot/modules/campaigns/views/campaigns_view.dart';
import 'package:watibot/modules/contacts/views/contacts_view.dart';

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
      if (controller.loading.value && controller.dashboardData.value == null) {
        return _buildSkeleton();
      }

      if (controller.dashboardData.value == null) {
        return const Center(child: Text('No Data Available'));
      }

      final data = controller.dashboardData.value!;

      return RefreshIndicator(
        onRefresh: controller.refreshDashboard,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DashboardHeader(
                onNotificationTap: controller.openNotifications,
                onProfileTap: controller.openProfile,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: ChartCard(data: data),
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
                    return StatsCard(
                      statistic: data.statistics[index],
                      index: index,
                    );
                  },
                  childCount: data.statistics.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: DashboardSection(
                title: 'Recent Activity',
                actionTitle: 'View All',
                onActionTap: () {},
                child: Column(
                  children: data.recentActivities.asMap().entries.map((entry) {
                    return ActivityTile(
                      activity: entry.value,
                      isLast: entry.key == data.recentActivities.length - 1,
                    );
                  }).toList(),
                ),
              ),
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
