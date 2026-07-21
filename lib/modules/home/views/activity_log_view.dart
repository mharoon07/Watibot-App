import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/home/controllers/activity_log_controller.dart';
import 'package:watibot/modules/home/widgets/activity_tile.dart';

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Activity Log',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load activity logs',
                  style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadInitialData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.activities.isEmpty) {
          return Center(
            child: Text(
              'No recent activity found',
              style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF64748B)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadInitialData,
          color: const Color(0xFF3B82F6),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: controller.activities.length + (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.activities.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                );
              }

              final activity = controller.activities[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ActivityTile(
                  activity: activity,
                  isLast: true, // Hide the divider for standalone tiles
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
