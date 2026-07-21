import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/contacts/controllers/contacts_controller.dart';
import 'package:watibot/modules/contacts/widgets/contact_empty_state.dart';
import 'package:watibot/modules/contacts/widgets/contact_filter_chip.dart';
import 'package:watibot/modules/contacts/widgets/contact_loading.dart';
import 'package:watibot/modules/contacts/widgets/contact_search_bar.dart';
import 'package:watibot/modules/contacts/widgets/contact_stats_card.dart';
import 'package:watibot/modules/contacts/widgets/contact_tile.dart';
import 'package:watibot/modules/contacts/routes/contacts_routes.dart';
import 'package:watibot/modules/home/controllers/home_controller.dart';

class ContactsView extends GetView<ContactsController> {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search contacts...',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                          suffixIcon: const Icon(Icons.filter_list, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),

          Obx(() {
            if (controller.isLoading.value && controller.contacts.isEmpty) {
              return const SliverFillRemaining(child: ContactLoading());
            }

            if (controller.contacts.isEmpty && !controller.hasError.value) {
              return SliverFillRemaining(
                child: ContactEmptyState(onAddContact: () {}),
              );
            }
            
            if (controller.hasError.value && controller.contacts.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Failed to load contacts',
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == controller.contacts.length) {
                    return controller.isLoadingMore.value
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox(height: 80);
                  }
                  
                  final contact = controller.contacts[index];
                  return Column(
                    children: [
                      ContactTile(
                        contact: contact,
                        onTap: () {
                           Get.toNamed(ContactsRoutes.contactDetails, arguments: contact);
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                    ],
                  );
                },
                childCount: controller.contacts.length + 1,
              ),
            );
          }),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: GestureDetector(
          onTap: () {
            homeController?.openProfile();
          },
          child: Obx(() {
            final userName = homeController?.userName.value ?? 'User';
            final avatarUrl = homeController?.userAvatar.value ?? '';
            final initials = userName.isNotEmpty 
                ? userName.trim().split(RegExp(r'\s+')).take(2).map((s) => s.isNotEmpty ? s[0].toUpperCase() : '').join() 
                : 'U';
            
            return CircleAvatar(
              backgroundColor: const Color(0xFFF1F5F9),
              child: ClipOval(
                child: avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(initials),
                      )
                    : _buildInitialsAvatar(initials),
              ),
            );
          }),
        ),
      ),
      title: Column(
        children: [
          Text(
            'Contacts',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Manage customers and leads',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppTheme.textPrimary),
          onPressed: () {
            homeController?.openNotifications();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 32,
      height: 32,
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


}
