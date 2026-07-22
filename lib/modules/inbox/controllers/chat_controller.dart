import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/core/services/chat_cache_service.dart';
import 'package:watibot/modules/inbox/controllers/inbox_controller.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';

class ChatController extends GetxController {
  final InboxRepository _repository;
  final _cacheService = Get.find<ChatCacheService>();
  
  late final ConversationModel conversation;

  ChatController(this._repository);

  final messages = <MessageModel>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isTyping = false.obs;

  final textController = TextEditingController();
  final scrollController = ScrollController();

  final isUploadingMedia = false.obs;
  final uploadProgress = 0.0.obs;
  final uploadStatusText = ''.obs;

  final isRecordingVoice = false.obs;
  final voiceRecordDuration = 0.obs;

  final quickReplies = <Map<String, dynamic>>[].obs;
  final whatsappTemplates = <Map<String, dynamic>>[].obs;
  final replyToMessage = Rxn<MessageModel>();

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;

  int _currentPage = 1;
  bool _hasMore = true;
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    conversation = Get.arguments as ConversationModel;

    // Instant local cache display (0ms load time)
    final cached = _cacheService.getCachedMessages(conversation.id);
    if (cached.isNotEmpty) {
      messages.assignAll(cached);
      isLoading.value = false;
    }

    // Fetch latest messages from CRM in background
    fetchMessages(silent: cached.isNotEmpty);
    _markChatAsRead();

    scrollController.addListener(_onScroll);
    
    // Fast silent polling every 3 seconds for real-time CRM updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      pollMessages();
    });

    fetchQuickRepliesAndTemplates();
  }

  Future<void> fetchQuickRepliesAndTemplates() async {
    quickReplies.value = await _repository.fetchQuickReplies();
    whatsappTemplates.value = await _repository.fetchWhatsAppTemplates();
  }

  void _markChatAsRead() {
    if (conversation.unreadCount > 0) {
      try {
        final inboxController = Get.find<InboxController>();
        inboxController.markAsRead(conversation.id);
      } catch (e) {
        debugPrint('InboxController not found or error marking as read: $e');
      }
      _repository.markAsRead(conversation.id);
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    scrollController.dispose();
    textController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadOlderMessages();
    }
  }

  Future<void> fetchMessages({bool silent = false}) async {
    _currentPage = 1;
    if (!silent && messages.isEmpty) {
      isLoading.value = true;
    }
    try {
      final data = await _repository.getPaginatedMessages(
        conversation.id,
        messagePage: _currentPage,
      );
      
      final list = (data['messages'] as List<MessageModel>).reversed.toList();
      messages.assignAll(list);
      _hasMore = data['hasMore'] as bool;

      // Update cache
      _cacheService.saveMessages(conversation.id, messages.toList());
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pollMessages() async {
    try {
      final data = await _repository.getPaginatedMessages(
        conversation.id,
        messagePage: 1,
      );
      
      final fetchedList = data['messages'] as List<MessageModel>;
      bool changed = false;

      for (var newMsg in fetchedList.reversed) {
        final index = messages.indexWhere((m) => m.id == newMsg.id);
        if (index != -1) {
          if (messages[index].status != newMsg.status || messages[index].content != newMsg.content) {
            messages[index] = newMsg;
            changed = true;
          }
        } else {
          messages.insert(0, newMsg);
          changed = true;
        }
      }

      if (changed) {
        _cacheService.saveMessages(conversation.id, messages.toList());
      }
    } catch (e) {
      debugPrint('Silent poll failed: $e');
    }
  }

  Future<void> loadOlderMessages() async {
    if (isLoadingMore.value || !_hasMore || isLoading.value) return;

    isLoadingMore.value = true;
    try {
      _currentPage++;
      final data = await _repository.getPaginatedMessages(
        conversation.id,
        messagePage: _currentPage,
      );
      
      final newMessages = (data['messages'] as List<MessageModel>).reversed.toList();
      _hasMore = data['hasMore'] as bool;

      for (var msg in newMessages) {
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
        }
      }
    } catch (e) {
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // --- MESSAGE SENDING API INTEGRATIONS ---

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = MessageModel(
      id: tempId,
      content: text,
      timestamp: DateTime.now(),
      type: MessageType.outgoing,
      status: MessageStatus.none,
    );

    messages.insert(0, tempMsg);
    textController.clear();
    _scrollToBottom();
    _cacheService.saveMessages(conversation.id, messages.toList());

    try {
      final sentMsg = await _repository.sendLiveChatMessage(
        contactId: conversation.id,
        message: text,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = sentMsg;
      } else {
        messages.insert(0, sentMsg);
      }
      _cacheService.saveMessages(conversation.id, messages.toList());
    } catch (e) {
      Get.snackbar('Send Error', ApiService.extractErrorMessage(e, 'Failed to send message'), snackPosition: SnackPosition.BOTTOM);
      messages.removeWhere((m) => m.id == tempId);
      _cacheService.saveMessages(conversation.id, messages.toList());
    }
  }

  Future<void> pickAndSendImage({bool fromCamera = false}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        showMediaCaptionPreview(File(file.path), file.name, 'image');
      }
    } catch (e) {
      Get.snackbar('Image Picker Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickAndSendVideo({bool fromCamera = false}) async {
    try {
      final XFile? file = await _picker.pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (file != null) {
        showMediaCaptionPreview(File(file.path), file.name, 'video');
      }
    } catch (e) {
      Get.snackbar('Video Picker Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickAndSendDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        await _sendMediaFile(File(platformFile.path!), platformFile.name, 'document');
      }
    } catch (e) {
      Get.snackbar('Document Picker Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickAndSendAudioFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        await _sendMediaFile(File(platformFile.path!), platformFile.name, 'audio');
      }
    } catch (e) {
      Get.snackbar('Audio Picker Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> startVoiceRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
        isRecordingVoice.value = true;
        voiceRecordDuration.value = 0;
        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          voiceRecordDuration.value++;
        });
      } else {
        Get.snackbar('Permission Denied', 'Microphone permission is required to record voice notes', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Recording Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> stopAndSendVoiceRecording() async {
    try {
      _recordingTimer?.cancel();
      final path = await _audioRecorder.stop();
      isRecordingVoice.value = false;
      voiceRecordDuration.value = 0;

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await _sendMediaFile(file, 'Voice Note.m4a', 'audio');
        }
      }
    } catch (e) {
      isRecordingVoice.value = false;
      Get.snackbar('Voice Note Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> cancelVoiceRecording() async {
    _recordingTimer?.cancel();
    await _audioRecorder.stop();
    isRecordingVoice.value = false;
    voiceRecordDuration.value = 0;
  }


  void showMediaCaptionPreview(File file, String fileName, String contentType) {
    final captionController = TextEditingController();

    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            contentType == 'image' ? 'Preview Image' : 'Preview Video',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: contentType == 'image'
                    ? Image.file(file, fit: BoxFit.contain)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library, size: 64, color: Colors.white),
                          SizedBox(height: 12),
                          Text('Video Selected', style: TextStyle(color: Colors.white)),
                        ],
                      ),
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black87,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: captionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.grey.shade900,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: const Color(0xFF00B074),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () {
                        Get.back();
                        sendMediaFileWithCaption(file, fileName, contentType, caption: captionController.text.trim());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendMediaFileWithCaption(File file, String fileName, String contentType, {String? caption}) async {
    await _sendMediaFile(file, fileName, contentType, caption: caption);
  }

  Future<void> _sendMediaFile(File file, String fileName, String contentType, {String? caption}) async {
    final fileSizeInBytes = await file.length();
    final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (contentType == 'video' || contentType == 'audio') {
      if (fileSizeInBytes > 16 * 1024 * 1024) {
        Get.snackbar(
          'File Too Large',
          'WhatsApp requires ${contentType == "video" ? "videos" : "audio files"} to be under 16 MB. Selected file is ${fileSizeInMB.toStringAsFixed(1)} MB.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFEF2F2),
          colorText: const Color(0xFF991B1B),
          duration: const Duration(seconds: 5),
        );
        return;
      }
    } else if (contentType == 'image') {
      if (fileSizeInBytes > 5 * 1024 * 1024) {
        Get.snackbar(
          'File Too Large',
          'WhatsApp requires images to be under 5 MB. Selected image is ${fileSizeInMB.toStringAsFixed(1)} MB.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFEF2F2),
          colorText: const Color(0xFF991B1B),
          duration: const Duration(seconds: 5),
        );
        return;
      }
    }

    isUploadingMedia.value = true;
    uploadProgress.value = 0.0;
    uploadStatusText.value = 'Uploading $fileName...';

    // Content: empty string for image/video/audio unless caption provided, filename only for document
    final String safeCaption = (contentType == 'audio' || contentType == 'voice') ? '' : (caption ?? '');
    final String initialContent = (contentType == 'document')
        ? (safeCaption.isNotEmpty ? safeCaption : fileName)
        : safeCaption;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final tempMsg = MessageModel(
      id: tempId,
      content: initialContent,
      timestamp: DateTime.now(),
      type: MessageType.outgoing,
      status: MessageStatus.none,
      attachmentUrl: file.path,
      attachmentType: _attachmentTypeFromContentType(contentType),
      uploadProgress: 0.0,
    );

    messages.insert(0, tempMsg);
    _scrollToBottom();

    try {
      final uploadRes = await _repository.uploadMedia(
        filePath: file.path,
        fileName: fileName,
        onProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            uploadProgress.value = progress;
            final idx = messages.indexWhere((m) => m.id == tempId);
            if (idx != -1) {
              messages[idx] = MessageModel(
                id: tempMsg.id,
                content: tempMsg.content,
                timestamp: tempMsg.timestamp,
                type: tempMsg.type,
                status: MessageStatus.none,
                attachmentUrl: tempMsg.attachmentUrl,
                attachmentType: tempMsg.attachmentType,
                uploadProgress: progress,
              );
              messages.refresh();
            }
          }
        },
      );

      uploadStatusText.value = 'Sending message...';
      final mediaUrl = uploadRes['url'] as String;

      final sentMsg = await _repository.sendLiveChatMessage(
        contactId: conversation.id,
        message: initialContent,
        mediaUrl: mediaUrl,
        contentType: contentType,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = sentMsg;
      }
    } catch (e) {
      Get.snackbar('Upload Error', ApiService.extractErrorMessage(e, 'Failed to upload media'), snackPosition: SnackPosition.BOTTOM);
      messages.removeWhere((m) => m.id == tempId);
    } finally {
      isUploadingMedia.value = false;
      uploadProgress.value = 0.0;
      uploadStatusText.value = '';
    }
  }


  AttachmentType _attachmentTypeFromContentType(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'image': return AttachmentType.image;
      case 'video': return AttachmentType.video;
      case 'audio': return AttachmentType.voice;
      default: return AttachmentType.document;
    }
  }

  Future<void> sendQuickReply(Map<String, dynamic> quickReply) async {
    final content = quickReply['content']?.toString() ?? quickReply['text']?.toString() ?? '';
    final fileUrl = quickReply['fileUrl']?.toString() ?? quickReply['file_url']?.toString();
    final type = quickReply['type']?.toString() ?? 'text';

    if (type == 'text' || fileUrl == null) {
      textController.text = content;
      await sendMessage();
    } else {
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempMsg = MessageModel(
        id: tempId,
        content: content.isNotEmpty ? content : 'Quick Reply',
        timestamp: DateTime.now(),
        type: MessageType.outgoing,
        status: MessageStatus.none,
        attachmentUrl: fileUrl,
        attachmentType: _attachmentTypeFromContentType(type),
      );

      messages.insert(0, tempMsg);
      _scrollToBottom();

      try {
        final sentMsg = await _repository.sendLiveChatMessage(
          contactId: conversation.id,
          message: content,
          mediaUrl: fileUrl,
          contentType: type,
        );

        final index = messages.indexWhere((m) => m.id == tempId);
        if (index != -1) {
          messages[index] = sentMsg;
        }
      } catch (e) {
        Get.snackbar('Send Error', ApiService.extractErrorMessage(e, 'Failed to send quick reply'), snackPosition: SnackPosition.BOTTOM);
        messages.removeWhere((m) => m.id == tempId);
      }
    }
  }

  Future<void> sendWhatsAppTemplate({
    required String templateName,
    required String language,
    List<dynamic>? parameters,
  }) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = MessageModel(
      id: tempId,
      content: 'Template: $templateName',
      timestamp: DateTime.now(),
      type: MessageType.outgoing,
      status: MessageStatus.none,
    );

    messages.insert(0, tempMsg);
    _scrollToBottom();

    try {
      final components = parameters != null && parameters.isNotEmpty
          ? [
              {
                'type': 'body',
                'parameters': parameters.map((val) => {'type': 'text', 'text': val.toString()}).toList(),
              }
            ]
          : null;

      final sentMsg = await _repository.sendLiveChatMessage(
        contactId: conversation.id,
        templateName: templateName,
        templateLanguage: language,
        components: components,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = sentMsg;
      }
    } catch (e) {
      Get.snackbar('Template Error', ApiService.extractErrorMessage(e, 'Failed to send template message'), snackPosition: SnackPosition.BOTTOM);
      messages.removeWhere((m) => m.id == tempId);
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void openContactDetails() {
    Get.toNamed('/contacts/details', arguments: conversation);
  }
}
