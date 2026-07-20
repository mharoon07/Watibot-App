import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/contacts/controllers/contacts_controller.dart';
import 'package:watibot/modules/contacts/widgets/add_contact_fab.dart';
import 'package:watibot/modules/contacts/widgets/contact_empty_state.dart';
import 'package:watibot/modules/contacts/widgets/contact_filter_chip.dart';
import 'package:watibot/modules/contacts/widgets/contact_loading.dart';
import 'package:watibot/modules/contacts/widgets/contact_search_bar.dart';
import 'package:watibot/modules/contacts/widgets/contact_stats_card.dart';
import 'package:watibot/modules/contacts/widgets/contact_tile.dart';
import 'package:watibot/modules/contacts/routes/contacts_routes.dart';

class ContactsView extends GetView<ContactsController> {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: CustomScrollView(
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
                    child: ContactSearchBar(onChanged: controller.searchContacts),
                  ),
                  Obx(() => ContactFilterChip(
                        chips: controller.filterChips,
                        selectedIndex: controller.selectedFilter.value,
                        onSelected: controller.changeFilter,
                      )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildStatsOverview(),
          ),
          Obx(() {
            if (controller.loading.value && controller.contacts.isEmpty) {
              return const SliverFillRemaining(child: ContactLoading());
            }

            if (controller.filteredContacts.isEmpty) {
              return SliverFillRemaining(
                child: ContactEmptyState(onAddContact: controller.addContact),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final contact = controller.filteredContacts[index];
                  // Add bottom padding to last item to prevent FAB overlap
                  final isLast = index == controller.filteredContacts.length - 1;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 100 : 1),
                    child: ContactTile(
                      contact: contact,
                      onTap: () => Get.toNamed(ContactsRoutes.contactDetails, arguments: contact),
                      onCall: () => controller.callContact(contact),
                      onChat: () => controller.openChat(contact),
                      onFavorite: () => controller.toggleFavorite(contact.id),
                      onBlock: () => controller.blockContact(contact.id),
                      onArchive: () => controller.archiveContact(contact.id),
                      onDelete: () => controller.deleteContact(contact.id),
                    ),
                  );
                },
                childCount: controller.filteredContacts.length,
              ),
            );
          }),
        ],
      ),
      floatingActionButton: AddContactFab(onPressed: controller.addContact),
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
          backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=68'), // Current user
        ),
      ),
      title: Column(
        children: [
          Text(
            'Contacts',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            'Manage customers and leads',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF475569)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: const [
          ContactStatsCard(
            title: 'Total Contacts',
            value: '12,450',
            icon: Icons.people_outline,
            color: Color(0xFF3B82F6),
          ),
          SizedBox(width: 12),
          ContactStatsCard(
            title: 'Active Today',
            value: '842',
            icon: Icons.bolt,
            color: Color(0xFF25D366),
          ),
          SizedBox(width: 12),
          ContactStatsCard(
            title: 'New This Week',
            value: '156',
            icon: Icons.trending_up,
            color: Color(0xFF8B5CF6),
          ),
          SizedBox(width: 12),
          ContactStatsCard(
            title: 'Favorites',
            value: '45',
            icon: Icons.star_border,
            color: Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}
