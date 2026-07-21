import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/modules/inbox/controllers/inbox_controller.dart';

class FilterChipList extends GetView<InboxController> {
  FilterChipList({super.key});

  final List<Map<String, dynamic>> filters = [
    {'label': 'All', 'icon': null},
    {'label': 'Unread', 'icon': null},
    {'label': 'Assigned Chat', 'icon': Icons.person},
    {'label': 'AI Chat', 'icon': Icons.smart_toy},
    {'label': 'Intervented Chat', 'icon': Icons.support_agent},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final label = filter['label'] as String;
          final icon = filter['icon'] as IconData?;

          return Obx(() {
            final isSelected = controller.activeFilter.value == label;

            return Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.setActiveFilter(label),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.fromBorderSide(
                        BorderSide(
                          color: isSelected ? AppTheme.primaryColor.withOpacity(0.3) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 16,
                            color: isSelected ? AppTheme.primaryColor : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppTheme.primaryColor : const Color(0xFF475569),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
