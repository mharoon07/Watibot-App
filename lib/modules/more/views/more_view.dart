import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:watibot/core/services/storage_service.dart';
import 'package:watibot/modules/auth/routes/auth_routes.dart';
import 'package:watibot/modules/more/widgets/more_menu_tile.dart';
import 'package:watibot/modules/more/widgets/more_profile_card.dart';
import 'package:watibot/modules/more/widgets/more_section_header.dart';
import 'package:watibot/modules/more/widgets/more_stats_row.dart';

import 'package:watibot/modules/more/controllers/more_controller.dart';

class MoreView extends GetView<MoreController> {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'More',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Settings, tools & account management',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF475569)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF475569)),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Obx(() => MoreProfileCard(
              avatarUrl: controller.userAvatar.value.isNotEmpty 
                  ? controller.userAvatar.value 
                  : (controller.workspaceLogo.value.isNotEmpty ? controller.workspaceLogo.value : 'https://i.pravatar.cc/150?img=68'),
              name: controller.userName.value,
              role: controller.userRole.value,
              workspace: controller.workspaceName.value,
              onEditProfile: controller.openProfileDetails,
            )),
          ),
          const SliverToBoxAdapter(
            child: MoreStatsRow(),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // Content Section
              const MoreSectionHeader(title: 'Content'),
              _buildSectionContainer([
                MoreMenuTile(
                  title: 'Templates',
                  subtitle: 'Create and manage WhatsApp templates',
                  icon: Icons.dashboard_customize_outlined,
                  color: const Color(0xFF3B82F6),
                  onTap: () {},
                ),
                _buildDivider(),
                MoreMenuTile(
                  title: 'Media Library',
                  subtitle: 'Images, videos, and documents',
                  icon: Icons.perm_media_outlined,
                  color: const Color(0xFF8B5CF6),
                  onTap: () {},
                ),
              ]),

              // Team Section
              const MoreSectionHeader(title: 'Team'),
              _buildSectionContainer([
                MoreMenuTile(
                  title: 'Agents',
                  subtitle: 'Manage your support and sales team',
                  icon: Icons.support_agent_outlined,
                  color: const Color(0xFF25D366),
                  onTap: () {},
                ),
                _buildDivider(),
                MoreMenuTile(
                  title: 'Audience',
                  subtitle: 'Customer segments and tags',
                  icon: Icons.people_outline,
                  color: const Color(0xFFEC4899),
                  onTap: () {},
                ),
              ]),

              // Communication Section
              const MoreSectionHeader(title: 'Communication'),
              _buildSectionContainer([
                MoreMenuTile(
                  title: 'Notifications',
                  subtitle: 'Push, email, and sound preferences',
                  icon: Icons.notifications_none_outlined,
                  color: const Color(0xFF6366F1),
                  onTap: () {},
                ),
              ]),

              // Workspace Section
              const MoreSectionHeader(title: 'Workspace'),
              _buildSectionContainer([
                MoreMenuTile(
                  title: 'Settings',
                  subtitle: 'General workspace configurations',
                  icon: Icons.settings_outlined,
                  color: const Color(0xFF64748B),
                  onTap: () {},
                ),
                _buildDivider(),
                MoreMenuTile(
                  title: 'Integrations',
                  subtitle: 'Connect Shopify, Zapier, etc.',
                  icon: Icons.api_outlined,
                  color: const Color(0xFF10B981),
                  onTap: () {},
                ),
                _buildDivider(),
                MoreMenuTile(
                  title: 'Billing',
                  subtitle: 'Invoices and payment methods',
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFF3B82F6),
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 24),
              // Support & Logout
              _buildSectionContainer([
                MoreMenuTile(
                  title: 'Help Center',
                  icon: Icons.help_outline,
                  color: const Color(0xFF64748B),
                  onTap: () {},
                ),
                _buildDivider(),
                MoreMenuTile(
                  title: 'Privacy Policy',
                  icon: Icons.shield_outlined,
                  color: const Color(0xFF64748B),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 16),
              _buildSectionContainer([
                MoreMenuTile(
                  title: 'Logout',
                  icon: Icons.logout_outlined,
                  color: const Color(0xFFDC2626),
                  isDestructive: true,
                  onTap: () async {
                    await Get.find<StorageService>().clearAll();
                    Get.offAllNamed(AuthRoutes.login);
                  },
                ),
              ]),

              // Version Info
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'WatiBot App',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0 (Build 42)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(height: 100), // Spacing for bottom nav
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
      indent: 68, // Aligns with the text
      endIndent: 16,
    );
  }
}
