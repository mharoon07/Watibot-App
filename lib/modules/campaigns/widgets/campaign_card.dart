import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/campaigns/models/campaign_model.dart';
import 'package:watibot/modules/campaigns/routes/campaigns_routes.dart';
import 'package:watibot/modules/campaigns/widgets/campaign_progress.dart';
import 'package:watibot/modules/campaigns/widgets/campaign_stat_chip.dart';
import 'package:watibot/modules/campaigns/widgets/campaign_status_badge.dart';
import 'package:intl/intl.dart';

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onDuplicate;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onPause,
    required this.onResume,
    required this.onDuplicate,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(CampaignsRoutes.campaignDetails, arguments: campaign),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row (Status + Type + Overflow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CampaignStatusBadge(status: campaign.status),
                _buildOverflowMenu(),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              campaign.name,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),

            // Meta info (Date + Audience)
            Row(
              children: [
                _buildMetaColumn('Date', _formatDate(campaign.createdAt, campaign.status)),
                const SizedBox(width: 32),
                _buildMetaColumn(
                  'Audience',
                  campaign.isDynamicAudience ? 'Dynamic' : NumberFormat.compact().format(campaign.audienceCount),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dynamic Stats Row
            _buildDynamicStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicStats() {
    if (campaign.status == CampaignStatus.sending) {
      return CampaignProgress(progress: campaign.deliveryProgress);
    } else if (campaign.status == CampaignStatus.draft || campaign.status == CampaignStatus.scheduled) {
      return CampaignProgress(
        progress: 0.0,
        label: campaign.status == CampaignStatus.draft ? 'Draft Saved' : 'Scheduled',
      );
    } else if (campaign.status == CampaignStatus.paused) {
      return CampaignProgress(
        progress: campaign.deliveryProgress,
        label: 'Paused',
      );
    }

    return Row(
      children: [
        CampaignStatChip(
          label: 'Sent',
          value: _formatLargeNumber(campaign.messagesSent),
        ),
        const SizedBox(width: 32),
        if (campaign.openRate > 0)
          CampaignStatChip(
            label: 'Open Rate',
            value: '${(campaign.openRate * 100).toStringAsFixed(1)}%',
            valueColor: const Color(0xFF25D366),
          ),
        const SizedBox(width: 32),
        if (campaign.clickRate > 0)
          CampaignStatChip(
            label: 'Click Rate',
            value: '${(campaign.clickRate * 100).toStringAsFixed(1)}%',
            valueColor: const Color(0xFF3B82F6),
          ),
      ],
    );
  }

  Widget _buildOverflowMenu() {
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: Color(0xFF64748B), size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              break;
            case 'pause':
              onPause();
              break;
            case 'resume':
              onResume();
              break;
            case 'duplicate':
              onDuplicate();
              break;
            case 'archive':
              onArchive();
              break;
            case 'delete':
              onDelete();
              break;
          }
        },
        itemBuilder: (context) {
          return [
            if (campaign.status != CampaignStatus.completed)
              _buildPopupMenuItem('edit', Icons.edit_outlined, 'Edit'),
            if (campaign.status == CampaignStatus.running || campaign.status == CampaignStatus.sending)
              _buildPopupMenuItem('pause', Icons.pause_circle_outline, 'Pause'),
            if (campaign.status == CampaignStatus.paused)
              _buildPopupMenuItem('resume', Icons.play_circle_outline, 'Resume'),
            _buildPopupMenuItem('duplicate', Icons.copy_outlined, 'Duplicate'),
            if (campaign.status != CampaignStatus.archived)
              _buildPopupMenuItem('archive', Icons.archive_outlined, 'Archive'),
            _buildPopupMenuItem('delete', Icons.delete_outline, 'Delete', color: Colors.red),
          ];
        },
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, String label, {Color color = const Color(0xFF0F172A)}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, CampaignStatus status) {
    if (status == CampaignStatus.running) return 'Ongoing';
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatLargeNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
