import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:watibot/modules/media_library/models/media_item_model.dart';
import 'package:watibot/modules/media_library/repositories/media_library_repository.dart';

class MediaLibraryController extends GetxController {

  final MediaLibraryRepository _repository = MediaLibraryRepository();
  final ImagePicker _picker = ImagePicker();

  final RxList<MediaItemModel> mediaItems = <MediaItemModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isUploading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString activeTab = 'image'.obs; // image, gif, audio, video, document
  final RxString searchQuery = ''.obs;

  final Rx<MediaItemModel?> selectedItem = Rx<MediaItemModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchMediaItems();
  }

  Future<void> fetchMediaItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getMediaItems(
        search: searchQuery.value,
        type: 'ALL',
      );

      final List<MediaItemModel> list = result['items'] ?? [];
      mediaItems.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
      mediaItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void onTabChanged(String tab) {
    activeTab.value = tab.toLowerCase();
  }

  int get imageCount => mediaItems.where((i) => i.type == 'image').length;
  int get gifCount => mediaItems.where((i) => i.type == 'gif').length;
  int get audioCount => mediaItems.where((i) => i.type == 'audio').length;
  int get videoCount => mediaItems.where((i) => i.type == 'video').length;
  int get documentCount => mediaItems.where((i) => i.type == 'document').length;

  List<MediaItemModel> get filteredItems {
    return mediaItems.where((item) {
      final matchesTab = item.type == activeTab.value;
      final matchesSearch = searchQuery.value.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();
  }

  Future<void> uploadFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      await _uploadPickedFile(file.path, file.name, 'image');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> uploadFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (file == null) return;
      await _uploadPickedFile(file.path, file.name, 'image');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> uploadVideoFromGallery() async {
    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;
      await _uploadPickedFile(file.path, file.name, 'video');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> uploadDocumentOrAudio({bool isAudio = false}) async {
    try {
      final result = await FilePicker.pickFiles(
        type: isAudio ? FileType.audio : FileType.any,
      );





      if (result == null || result.files.isEmpty) return;
      final picked = result.files.first;
      if (picked.path == null) return;

      final type = isAudio ? 'audio' : 'document';
      await _uploadPickedFile(picked.path!, picked.name, type);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _uploadPickedFile(String filePath, String fileName, String type) async {
    try {
      isUploading.value = true;
      final uploadedUrl = await _repository.uploadFile(filePath, fileName);
      final newItem = await _repository.addMediaItem(
        name: fileName,
        url: uploadedUrl,
        type: type,
      );
      mediaItems.insert(0, newItem);
      activeTab.value = type;
      Get.snackbar('Success', '$fileName uploaded successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> addMediaItem({required String name, required String url, required String type}) async {
    try {
      isUploading.value = true;
      final newItem = await _repository.addMediaItem(name: name, url: url, type: type);
      mediaItems.insert(0, newItem);
    } catch (e) {
      rethrow;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteMediaItem(MediaItemModel item) async {
    try {
      final success = await _repository.deleteMediaItem(item.id);
      if (success) {
        mediaItems.removeWhere((i) => i.id == item.id);
      }
    } catch (e) {
      // Optimistically remove
      mediaItems.removeWhere((i) => i.id == item.id);
    }
  }
}

