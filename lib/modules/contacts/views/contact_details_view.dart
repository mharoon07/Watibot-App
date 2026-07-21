import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/contacts/models/contact_model.dart';
import 'package:watibot/modules/contacts/widgets/contact_avatar.dart';
import 'package:watibot/modules/contacts/widgets/contact_status_badge.dart';
import 'package:intl/intl.dart';

class ContactDetailsView extends StatelessWidget {
  const ContactDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactModel contact = Get.arguments as ContactModel;
    final isOnline = contact.lastMessageAt != null 
        ? DateTime.now().difference(contact.lastMessageAt!).inMinutes <= 10 
        : false;

    final String phone = contact.phoneNumber ?? contact.waId ?? '';
    final String company = (contact.attributes['company'] as String?) ?? '';
    final String status = contact.tags.isNotEmpty ? contact.tags.first.name : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF475569), size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Color(0xFF475569)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF475569)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  ContactAvatar(
                    imageUrl: contact.profilePic ?? '',
                    name: contact.initials,
                    size: 80,
                    isOnline: isOnline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    contact.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company.isNotEmpty ? '$company • $phone' : phone,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (status.isNotEmpty)
                        ContactStatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            
            // Details Sections
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard('Contact Information', [
                    _buildInfoRow(Icons.email_outlined, 'Email', contact.email ?? ''),
                    _buildInfoRow(Icons.phone_outlined, 'Phone', phone),
                    _buildInfoRow(Icons.business_outlined, 'Company', company),
                  ]),
                  const SizedBox(height: 16),
                  if (contact.tags.isNotEmpty)
                    _buildSectionCard('Tags', [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: contact.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag.name,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        )).toList(),
                      ),
                    ]),
                  const SizedBox(height: 16),
                  if (contact.attributes.isNotEmpty) ...[
                    _buildSectionCard('Custom Fields', contact.attributes.entries.map((e) {
                      return _buildInfoRow(Icons.label_important_outline, e.key.toUpperCase(), e.value.toString());
                    }).toList()),
                    const SizedBox(height: 16),
                  ],
                  _buildSectionCard('Activity', [
                    if (contact.lastMessageAt != null)
                      _buildInfoRow(Icons.access_time, 'Last Message', _formatDetailedDate(contact.lastMessageAt!)),
                    if (contact.createdAt != null)
                      _buildInfoRow(Icons.sync, 'Created At', _formatDetailedDate(contact.createdAt!)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final displayValue = value.isEmpty ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayValue,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDetailedDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
}
