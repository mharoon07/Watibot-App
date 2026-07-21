import 'package:flutter/material.dart';
import 'package:watibot/modules/home/controllers/home_controller.dart' as watibot_home;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/campaigns/controllers/campaigns_controller.dart';
import 'package:watibot/modules/campaigns/widgets/campaign_card.dart';
import 'package:watibot/modules/campaigns/widgets/campaign_filter_tabs.dart';
import 'package:watibot/modules/campaigns/widgets/campaign_search.dart';
import 'package:watibot/modules/campaigns/widgets/empty_campaign.dart';
import 'package:watibot/modules/campaigns/widgets/floating_create_button.dart';
import 'package:watibot/modules/campaigns/widgets/loading_campaign.dart';

class CampaignsView extends GetView<CampaignsController> {
  const CampaignsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CampaignSearch(onChanged: controller.searchCampaign),
                ),
                Obx(() => CampaignFilterTabs(
                      tabs: controller.tabs,
                      selectedIndex: controller.selectedTab.value,
                      onTabSelected: controller.changeTab,
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.campaigns.isEmpty) {
                return const LoadingCampaign();
              }

              if (controller.filteredCampaigns.isEmpty) {
                return EmptyCampaign(onCreate: controller.createCampaign);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshCampaigns,
                color: const Color(0xFF25D366),
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.filteredCampaigns.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final campaign = controller.filteredCampaigns[index];
                    return CampaignCard(
                      campaign: campaign,
                      onPause: () => controller.pauseCampaign(campaign.id),
                      onResume: () => controller.resumeCampaign(campaign.id),
                      onDuplicate: () => controller.duplicateCampaign(campaign.id),
                      onArchive: () => controller.archiveCampaign(campaign.id),
                      onDelete: () => controller.deleteCampaign(campaign.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingCreateButton(
        onPressed: controller.createCampaign,
      ),
    );
  }

  AppBar _buildAppBar() {
    final homeController = Get.find<watibot_home.HomeController>();
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: homeController.openProfile,
          child: Obx(() => CircleAvatar(
            backgroundColor: const Color(0xFFE2E8F0),
            backgroundImage: NetworkImage(
              homeController.userAvatar.value.isNotEmpty 
                  ? homeController.userAvatar.value 
                  : 'https://i.pravatar.cc/150?img=47'
            ),
          )),
        ),
      ),
      title: Column(
        children: [
          Text(
            'Campaigns',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            'Manage automated messaging flows',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Stack(
              children: [
                Icon(Icons.notifications_none_rounded, color: Color(0xFF475569), size: 28),
                Positioned(
                  right: 2,
                  top: 2,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
            onPressed: homeController.openNotifications,
          ),
        ),
      ],
    );
  }
}
