import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/home/widgets/workspace_progress_bar.dart';
import 'package:watibot/modules/home/widgets/workspace_status_chip.dart';

class WorkspaceOverviewCard extends StatelessWidget {
  const WorkspaceOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildGrid(),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildUsageOverview(),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace Status',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your WhatsApp Business account overview',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8), size: 20),
            tooltip: 'Refresh Status',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildGridTile(
                    title: 'Quality Rating',
                    content: const WorkspaceStatusChip(
                      text: 'UNKNOWN',
                      color: Color(0xFF94A3B8), // Grey
                    ),
                    description: 'No rating data available yet',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridTile(
                    title: 'WhatsApp API',
                    content: const WorkspaceStatusChip(
                      text: 'LIVE',
                      color: Color(0xFF25D366), // WatiBot Green
                      isPulsing: true,
                    ),
                    description: 'Connected successfully',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildGridTile(
                    title: 'Current Plan',
                    content: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'FREE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    description: 'Forever Free',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridTile(
                    title: 'Phone Number',
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '+92 328 988 9675',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Color(0xFF25D366), size: 14),
                      ],
                    ),
                    description: 'Verified business account',
                    onTapCopy: () {
                      Clipboard.setData(const ClipboardData(text: '+923289889675'));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTile({
    required String title,
    required Widget content,
    required String description,
    VoidCallback? onTapCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              if (onTapCopy != null)
                GestureDetector(
                  onTap: onTapCopy,
                  child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF94A3B8)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          content,
          const Spacer(),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageOverview() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage Overview',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const WorkspaceProgressBar(
            label: 'Conversations',
            current: 68,
            max: 250,
            color: Color(0xFF25D366), // WatiBot Green
          ),
          const SizedBox(height: 12),
          const WorkspaceProgressBar(
            label: 'Templates',
            current: 15,
            max: 50,
            color: Color(0xFF25D366),
          ),
          const SizedBox(height: 12),
          const WorkspaceProgressBar(
            label: 'Broadcasts',
            current: 3,
            max: 10,
            color: Color(0xFF25D366),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 250) {
            // Stack vertically on very small screens
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFooterStat('Connected Since', 'Jan 2025'),
                    _buildFooterStat('Last Sync', '2 mins ago'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildUpgradeButton(),
              ],
            );
          }

          // Horizontal row for normal screens
          return Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    _buildFooterStat('Connected Since', 'Jan 2025'),
                    _buildFooterStat('Last Sync', '2 mins ago'),
                  ],
                ),
              ),
              _buildUpgradeButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0F172A),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(0, 36),
      ),
      child: Text(
        'Upgrade',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooterStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
