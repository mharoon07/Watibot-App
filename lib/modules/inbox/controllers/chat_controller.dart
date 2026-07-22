import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/modules/inbox/controllers/inbox_controller.dart';
import 'package:watibot/modules/inbox/models/conversation_model.dart';
import 'package:watibot/modules/inbox/models/message_model.dart';
import 'package:watibot/modules/inbox/repositories/inbox_repository.dart';

class ChatController extends GetxController {
  final InboxRepository _repository;
  
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
    fetchMessages();
    _markChatAsRead();

    scrollController.addListener(_onScroll);
    
    // Start silent polling every 5 seconds for new messages and status updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
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

  Future<void> fetchMessages() async {
    _currentPage = 1;
    isLoading.value = true;
    try {
      final data = await _repository.getPaginatedMessages(
        conversation.id,
        messagePage: _currentPage,
      );
      
      final list = (data['messages'] as List<MessageModel>).reversed.toList();
      messages.assignAll(list);
      _hasMore = data['hasMore'] as bool;
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
      for (var newMsg in fetchedList.reversed) {
        final index = messages.indexWhere((m) => m.id == newMsg.id);
        if (index != -1) {
          if (messages[index].status != newMsg.status || messages[index].content != newMsg.content) {
            messages[index] = newMsg;
          }
        } else {
          messages.insert(0, newMsg);
        }
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

    try {
      final sentMsg = await _repository.sendLiveChatMessage(
        contactId: conversation.id,
        message: text,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = sentMsg;
      }
    } catch (e) {
      Get.snackbar('Send Error', ApiService.extractErrorMessage(e, 'Failed to send message'), snackPosition: SnackPosition.BOTTOM);
      messages.removeWhere((m) => m.id == tempId);
    }
  }

  Future<void> pickAndSendImage({bool fromCamera = false}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        await _sendMediaFile(File(file.path), file.name, 'image');
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
        await _sendMediaFile(File(file.path), file.name, 'video');
      }
    } catch (e) {
      Get.snackbar('Video Picker Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickAndSendDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
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
        allowMultiple: false,
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

  Future<void> _sendMediaFile(File file, String fileName, String contentType) async {
    isUploadingMedia.value = true;
    uploadProgress.value = 0.0;
    uploadStatusText.value = 'Uploading $fileName...';

    try {
      final uploadRes = await _repository.uploadMedia(
        filePath: file.path,
        fileName: fileName,
        onProgress: (sent, total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
          }
        },
      );

      uploadStatusText.value = 'Sending message...';
      final mediaUrl = uploadRes['url'] as String;

      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempMsg = MessageModel(
        id: tempId,
        content: fileName,
        timestamp: DateTime.now(),
        type: MessageType.outgoing,
        status: MessageStatus.none,
        attachmentUrl: mediaUrl,
        attachmentType: _attachmentTypeFromContentType(contentType),
      );

      messages.insert(0, tempMsg);
      _scrollToBottom();

      final sentMsg = await _repository.sendLiveChatMessage(
        contactId: conversation.id,
        message: fileName,
        mediaUrl: mediaUrl,
        contentType: contentType,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = sentMsg;
      }
    } catch (e) {
      Get.snackbar('Upload Error', ApiService.extractErrorMessage(e, 'Failed to upload media'), snackPosition: SnackPosition.BOTTOM);
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
