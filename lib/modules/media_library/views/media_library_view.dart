import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/media_library/controllers/media_library_controller.dart';
import 'package:watibot/modules/media_library/models/media_item_model.dart';

class MediaLibraryView extends GetView<MediaLibraryController> {
  const MediaLibraryView({super.key});

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
              'Media Library',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Obx(() => Text(
              '${controller.mediaItems.length} items in workspace library',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            )),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF00B074)),
            onPressed: () => _showAddMediaDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: controller.fetchMediaItems,
            color: const Color(0xFF00B074),
            child: CustomScrollView(

          slivers: [
            // Search Input & Category Tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search media by file name...',
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
                          _buildTabTile('image', 'Images', Icons.image_outlined, controller.imageCount),
                          const SizedBox(width: 8),
                          _buildTabTile('gif', 'GIFs', Icons.auto_awesome_outlined, controller.gifCount),
                          const SizedBox(width: 8),
                          _buildTabTile('audio', 'Audio', Icons.audiotrack_outlined, controller.audioCount),
                          const SizedBox(width: 8),
                          _buildTabTile('video', 'Videos', Icons.videocam_outlined, controller.videoCount),
                          const SizedBox(width: 8),
                          _buildTabTile('document', 'Documents', Icons.description_outlined, controller.documentCount),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),

            // Media Grid Content
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
                            onPressed: controller.fetchMediaItems,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B074)),
                            child: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final list = controller.filteredItems;
              if (list.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.perm_media_outlined, size: 56, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          'No media files found',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Upload a new file or select a different category',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = list[index];
                      return _buildMediaCard(context, item);
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
      Obx(() {
        if (!controller.isUploading.value) return const SizedBox.shrink();
        return Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF00B074)),
                      const SizedBox(height: 16),
                      Text(
                        'Uploading media file...',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }




  Widget _buildTabTile(String key, String label, IconData icon, int count) {
    final isSelected = controller.activeTab.value == key;
    return InkWell(
      onTap: () => controller.onTabChanged(key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B074).withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF00B074) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF00B074) : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF00B074) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00B074) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard(BuildContext context, MediaItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
          onTap: () => _showPreviewDialog(context, item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Thumbnail
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        child: item.type == 'image' || item.type == 'gif'
                            ? Image.network(
                                item.url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8)),
                                ),

                              )
                            : Center(
                                child: Icon(
                                  item.type == 'video'
                                      ? Icons.videocam_outlined
                                      : item.type == 'audio'
                                          ? Icons.audiotrack_outlined
                                          : Icons.description_outlined,
                                  size: 40,
                                  color: const Color(0xFF00B074),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                        onPressed: () => _confirmDelete(context, item),
                      ),
                    ),
                  ],
                ),
              ),

              // Title and Date
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, MediaItemModel item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (item.type == 'image' || item.type == 'gif')
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(item.url, height: 300, fit: BoxFit.contain),
                )

              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.type == 'video'
                        ? Icons.videocam
                        : item.type == 'audio'
                            ? Icons.audiotrack
                            : Icons.description,
                    size: 64,
                    color: const Color(0xFF00B074),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B074),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMediaDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload Media',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a file from your device or gallery to upload',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUploadOptionTile(
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFF00B074),
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    controller.uploadFromGallery();
                  },
                ),
                _buildUploadOptionTile(
                  icon: Icons.camera_alt_outlined,
                  color: const Color(0xFF3B82F6),
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    controller.uploadFromCamera();
                  },
                ),
                _buildUploadOptionTile(
                  icon: Icons.videocam_outlined,
                  color: const Color(0xFF8B5CF6),
                  label: 'Video',
                  onTap: () {
                    Get.back();
                    controller.uploadVideoFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUploadOptionTile(
                  icon: Icons.audiotrack_outlined,
                  color: const Color(0xFFF59E0B),
                  label: 'Audio',
                  onTap: () {
                    Get.back();
                    controller.uploadDocumentOrAudio(isAudio: true);
                  },
                ),
                _buildUploadOptionTile(
                  icon: Icons.description_outlined,
                  color: const Color(0xFFEC4899),
                  label: 'Document',
                  onTap: () {
                    Get.back();
                    controller.uploadDocumentOrAudio(isAudio: false);
                  },
                ),
                _buildUploadOptionTile(
                  icon: Icons.link_rounded,
                  color: const Color(0xFF64748B),
                  label: 'URL Link',
                  onTap: () {
                    Get.back();
                    _showUrlInputDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOptionTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  void _showUrlInputDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    String selectedType = 'image';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Media by URL', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'File Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'Media URL'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              onChanged: (val) => selectedType = val ?? 'image',
              items: const [
                DropdownMenuItem(value: 'image', child: Text('Image')),
                DropdownMenuItem(value: 'gif', child: Text('GIF')),
                DropdownMenuItem(value: 'audio', child: Text('Audio')),
                DropdownMenuItem(value: 'video', child: Text('Video')),
                DropdownMenuItem(value: 'document', child: Text('Document')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty && urlController.text.trim().isNotEmpty) {
                await controller.addMediaItem(
                  name: nameController.text.trim(),
                  url: urlController.text.trim(),
                  type: selectedType,
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B074)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  void _confirmDelete(BuildContext context, MediaItemModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete File?'),
        content: Text('Are you sure you want to delete "${item.name}" from your Media Library?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.deleteMediaItem(item);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
