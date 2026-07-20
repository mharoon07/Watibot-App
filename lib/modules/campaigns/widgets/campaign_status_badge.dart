import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/campaigns/models/campaign_model.dart';

class CampaignStatusBadge extends StatelessWidget {
  final CampaignStatus status;

  const CampaignStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case CampaignStatus.sending:
        color = const Color(0xFF25D366); // Primary Green
        label = 'SENDING';
        break;
      case CampaignStatus.running:
        color = const Color(0xFF10B981); // Emerald
        label = 'ACTIVE';
        break;
      case CampaignStatus.scheduled:
        color = const Color(0xFFF59E0B); // Amber
        label = 'SCHEDULED';
        break;
      case CampaignStatus.paused:
        color = const Color(0xFF94A3B8); // Slate
        label = 'PAUSED';
        break;
      case CampaignStatus.completed:
        color = const Color(0xFF3B82F6); // Blue
        label = 'COMPLETED';
        break;
      case CampaignStatus.draft:
        color = const Color(0xFF64748B); // Slate darker
        label = 'DRAFT';
        break;
      case CampaignStatus.archived:
        color = const Color(0xFF475569); // Slate darker
        label = 'ARCHIVED';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: const Color(0xFF475569), // Text stays neutral, dot is colored
          ),
        ),
      ],
    );
  }
}
