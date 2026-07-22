import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/templates/controllers/templates_controller.dart';
import 'package:watibot/modules/templates/models/template_model.dart';
import 'package:watibot/modules/templates/views/template_details_view.dart';

class TemplatesView extends GetView<TemplatesController> {
  const TemplatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              'Message Templates',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Synced with Meta Business Suite',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00B074)),
            onPressed: () => Get.toNamed('/templates/create'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchTemplates,
        color: const Color(0xFF00B074),
        child: CustomScrollView(
          slivers: [
            // Status Stats Row
            SliverToBoxAdapter(
              child: Obx(() => Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard('Approved', controller.approvedCount.toString(), const Color(0xFF00B074), Icons.check_circle_outline)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard('Pending', controller.pendingCount.toString(), const Color(0xFFF59E0B), Icons.schedule)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard('Rejected', controller.rejectedCount.toString(), const Color(0xFFEF4444), Icons.error_outline)),
                  ],
                ),
              )),
            ),

            // Search Bar & Category Filter Pills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search templates...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryPill('ALL', 'All Categories'),
                          const SizedBox(width: 8),
                          _buildCategoryPill('MARKETING', 'Marketing'),
                          const SizedBox(width: 8),
                          _buildCategoryPill('UTILITY', 'Utility'),
                          const SizedBox(width: 8),
                          _buildCategoryPill('AUTHENTICATION', 'Auth'),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Templates List
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF00B074))),
                );
              }

              if (controller.errorMessage.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFFEF4444)),
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFEF4444)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.fetchTemplates,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B074)),
                            child: const Text('Retry Connection', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final list = controller.filteredTemplates;
              if (list.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.dashboard_customize_outlined, size: 56, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          'No templates found',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try adjusting your search or category filter',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = list[index];
                      return _buildTemplateCard(item);
                    },
                    childCount: list.length,
                  ),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(count, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String key, String label) {
    final isSelected = controller.selectedCategory.value == key;
    return InkWell(
      onTap: () => controller.onCategorySelected(key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B074) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF00B074) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(TemplateModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            controller.openTemplateDetails(item);
            Get.to(() => TemplateDetailsView(template: item));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.statusBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: item.statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.status,
                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: item.statusColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Badges Row
                Row(
                  children: [
                    _buildTagBadge(item.category, const Color(0xFFF1F5F9), const Color(0xFF475569)),
                    const SizedBox(width: 6),
                    _buildTagBadge(item.language, const Color(0xFFF1F5F9), const Color(0xFF475569)),
                    if (item.headerComponent != null) ...[
                      const SizedBox(width: 6),
                      _buildTagBadge(
                        item.headerComponent!.format ?? 'TEXT',
                        const Color(0xFF00B074).withOpacity(0.1),
                        const Color(0xFF00B074),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Text snippet preview
                Text(
                  item.text ?? item.bodyComponent?.text ?? 'No body text',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),

                // Footer Info Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.buttons.length} Buttons',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                    ),
                    Row(
                      children: [
                        Text(
                          'View details',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF00B074)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF00B074)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: text),
      ),
    );
  }
}
