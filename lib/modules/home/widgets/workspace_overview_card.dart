import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/home/widgets/workspace_progress_bar.dart';
import 'package:watibot/modules/home/widgets/workspace_status_chip.dart';
import 'package:watibot/modules/home/models/workspace_status_model.dart';
import 'package:watibot/modules/home/models/usage_overview_model.dart';

class WorkspaceOverviewCard extends StatelessWidget {
  final WorkspaceStatusModel? workspaceStatus;
  final UsageOverviewModel? usageOverview;

  const WorkspaceOverviewCard({
    super.key,
    this.workspaceStatus,
    this.usageOverview,
  });

  @override
  Widget build(BuildContext context) {
    if (workspaceStatus == null) return const SizedBox.shrink();

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
          if (usageOverview != null && usageOverview!.resources.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            _buildUsageOverview(),
          ],
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
                  workspaceStatus!.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: const Icon(
              Icons.business_center_outlined,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildGridTile(
                    title: 'WhatsApp API',
                    content: WorkspaceStatusChip(
                      text: workspaceStatus!.whatsappConnected ? 'LIVE' : 'OFFLINE',
                      color: workspaceStatus!.whatsappConnected ? const Color(0xFF25D366) : const Color(0xFF94A3B8),
                      isPulsing: workspaceStatus!.whatsappConnected,
                    ),
                    description: workspaceStatus!.whatsappConnected ? 'Connected successfully' : 'Not connected',
                  ),
                ),
                const SizedBox(width: 12),
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
                        workspaceStatus!.plan.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    description: 'Active Subscription',
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
                    title: 'Phone Number',
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            workspaceStatus!.whatsappNumber ?? 'N/A',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (workspaceStatus!.whatsappNumber != null) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Color(0xFF25D366), size: 14),
                        ]
                      ],
                    ),
                    description: workspaceStatus!.whatsappNumber != null ? 'Verified account' : 'No number',
                    onTapCopy: workspaceStatus!.whatsappNumber != null ? () {
                      Clipboard.setData(ClipboardData(text: workspaceStatus!.whatsappNumber!));
                    } : null,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Usage Overview',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),

            ],
          ),
          const SizedBox(height: 16),
          ...usageOverview!.resources.take(3).map((resource) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: WorkspaceProgressBar(
                label: resource.name,
                current: resource.used,
                max: resource.limit <= 0 ? resource.used + 1 : resource.limit,
                isUnlimited: resource.unlimited,
                color: const Color(0xFF25D366),
              ),
            );
          }).toList(),
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFooterStat('Project ID', workspaceStatus!.id.substring(0, 8)),
                    _buildFooterStat('Timezone', workspaceStatus!.timezone),
                  ],
                ),
                const SizedBox(height: 16),
                _buildUpgradeButton(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    _buildFooterStat('Project ID', workspaceStatus!.id.substring(0, 8)),
                    _buildFooterStat('Timezone', workspaceStatus!.timezone),
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
