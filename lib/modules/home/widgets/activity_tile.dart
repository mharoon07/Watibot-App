import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/home/models/dashboard_model.dart';

class ActivityTile extends StatelessWidget {
  final RecentActivity activity;
  final bool isLast;

  const ActivityTile({
    super.key,
    required this.activity,
    this.isLast = false,
  });

  IconData _getIcon() {
    switch (activity.type) {
      case 'campaign':
        return Icons.rocket_launch;
      case 'contact':
        return Icons.person_add;
      case 'flow':
        return Icons.account_tree;
      case 'broadcast':
        return Icons.campaign;
      case 'agent':
        return Icons.pause_circle_outline;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor() {
    switch (activity.type) {
      case 'campaign':
        return AppTheme.primaryColor;
      case 'contact':
        return Colors.blue;
      case 'flow':
        return Colors.purple;
      case 'broadcast':
        return Colors.orange;
      case 'agent':
        return Colors.redAccent;
      case 'payment':
        return Colors.green;
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(),
                  color: color,
                  size: 16,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppTheme.borderColor,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF475569),
                    ),
                    children: [
                      TextSpan(text: activity.subtitle.replaceAll(activity.title, '')),
                      TextSpan(
                        text: ' ${activity.title} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (activity.subtitle.contains('completed') || activity.subtitle.contains('paused'))
                        TextSpan(
                          text: activity.subtitle.split(activity.title).last.trim(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.timestamp,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
