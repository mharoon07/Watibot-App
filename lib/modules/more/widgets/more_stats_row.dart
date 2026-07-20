import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreStatsRow extends StatelessWidget {
  const MoreStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: 70,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildStatCard('Storage Used', '1.2 GB', Icons.storage_rounded, const Color(0xFF3B82F6)),
            const SizedBox(width: 12),
            _buildStatCard('Connected Accounts', '3', Icons.mark_chat_read_rounded, const Color(0xFF25D366)),
            const SizedBox(width: 12),
            _buildStatCard('Active AI Agents', '2', Icons.smart_toy_rounded, const Color(0xFF8B5CF6)),
            const SizedBox(width: 12),
            _buildStatCard('Subscription', 'Enterprise', Icons.workspace_premium_rounded, const Color(0xFFF59E0B)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
