import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/media_library/controllers/media_library_controller.dart';
import 'package:watibot/modules/media_library/models/media_item_model.dart';

class MediaLibraryModal extends StatefulWidget {
  final Function(String url, String name) onSelect;
  final String? initialType;

  const MediaLibraryModal({
    super.key,
    required this.onSelect,
    this.initialType,
  });

  @override
  State<MediaLibraryModal> createState() => _MediaLibraryModalState();
}

class _MediaLibraryModalState extends State<MediaLibraryModal> {
  late final MediaLibraryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MediaLibraryController());
    if (widget.initialType != null) {
      // Ensure tab is set if initialType is provided (e.g. image, video, document, audio)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.onTabChanged(widget.initialType!.toLowerCase());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Media Library',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00B074),
                      ),
                    ),
                    Obx(() => Text(
                      '${controller.mediaItems.length} items total in workspace library',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          
          // Search & Upload
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search media by file name...',
                      hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      fillColor: const Color(0xFFF8FAFC),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showAddMediaDialog(context),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.white),
                  label: Text('Upload New', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    backgroundColor: const Color(0xFF00B074),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: const Color(0xFF00B074).withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabs
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabTile('image', 'Image', Icons.image_outlined, controller.imageCount),
                  const SizedBox(width: 8),
                  _buildTabTile('gif', 'GIF', Icons.auto_awesome_outlined, controller.gifCount),
                  const SizedBox(width: 8),
                  _buildTabTile('audio', 'Audio', Icons.audiotrack_outlined, controller.audioCount),
                  const SizedBox(width: 8),
                  _buildTabTile('video', 'Video', Icons.videocam_outlined, controller.videoCount),
                  const SizedBox(width: 8),
                  _buildTabTile('document', 'Document', Icons.description_outlined, controller.documentCount),
                  const SizedBox(width: 24),
                ],
              ),
            )),
          ),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),

          // Grid
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: controller.fetchMediaItems,
                  color: const Color(0xFF00B074),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B074)));
                    }

                    if (controller.errorMessage.isNotEmpty) {
                      return Center(
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
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero,
                                backgroundColor: const Color(0xFF00B074),
                              ),
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }

                    final list = controller.filteredItems;
                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: const Icon(Icons.image_outlined, size: 32, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No files found',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF334155)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Upload a new file from your device.',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns for mobile modal
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return _buildMediaCard(list[index]);
                      },
                    );
                  }),
                ),

                // Uploading Overlay
                Obx(() {
                  if (!controller.isUploading.value) return const SizedBox.shrink();
                  return Container(
                    color: Colors.white.withValues(alpha: 0.8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20),
                          ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildTabTile(String key, String label, IconData icon, int count) {
    final isSelected = controller.activeTab.value == key;
    return InkWell(
      onTap: () => controller.onTabChanged(key),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B074).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF00B074) : const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? const Color(0xFF00B074) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00B074).withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF00B074) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard(MediaItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            widget.onSelect(item.url, item.name);
            Get.back();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Thumbnail
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
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
                                  ? Icons.videocam
                                  : item.type == 'audio'
                                      ? Icons.audiotrack
                                      : Icons.description,
                              size: 40,
                              color: const Color(0xFF00B074).withValues(alpha: 0.8),
                            ),
                          ),
                  ),
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
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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
              value: selectedType,
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
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: const Color(0xFF00B074),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
