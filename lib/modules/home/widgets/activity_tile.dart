import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/home/models/recent_activity_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityTile extends StatelessWidget {
  final RecentActivityModel activity;
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
        return Icons.smart_toy;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor() {
    switch (activity.type) {
      case 'campaign':
        return const Color(0xFF25D366); // Green
      case 'contact':
        return const Color(0xFF3B82F6); // Blue
      case 'flow':
        return const Color(0xFF6366F1); // Indigo
      case 'broadcast':
        return const Color(0xFFF59E0B); // Orange
      case 'agent':
        return const Color(0xFF8B5CF6); // Purple
      case 'payment':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  String _getActionTitle() {
    return '${activity.module[0].toUpperCase()}${activity.module.substring(1)} ${activity.action}';
  }

  String _getDescription() {
    return activity.displaySubtitle;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline Column
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(),
                          color: color,
                          size: 20,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: const Color(0xFFE2E8F0), // Subtle connector
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Content Column
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 8 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getActionTitle(),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activity.displayTitle,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDescription(),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.createdAt != null 
                              ? timeago.format(activity.createdAt!) 
                              : 'Just now',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
