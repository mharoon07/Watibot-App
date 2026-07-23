import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/templates/repositories/templates_repository.dart';

class CarouselCardState {
  String id;
  String headerType;
  String headerUrl;
  String body;
  List<ButtonState> buttons;

  CarouselCardState({
    required this.id,
    this.headerType = 'IMAGE',
    this.headerUrl = '',
    this.body = '',
    List<ButtonState>? buttons,
  }) : buttons = buttons ?? [];
}

class ButtonState {
  String type;
  String text;
  String? url;
  String? phoneNumber;

  ButtonState({
    required this.type,
    required this.text,
    this.url,
    this.phoneNumber,
  });
}

class CreateTemplateController extends GetxController {
  final TemplatesRepository _repository = Get.find<TemplatesRepository>();

  final isCreating = false.obs;

  // Form State
  final name = ''.obs;
  final category = 'MARKETING'.obs;
  final language = 'en_US'.obs;
  final templateType = 'STANDARD'.obs;
  
  final headerType = 'TEXT'.obs;
  final headerText = ''.obs;
  final headerFileUrl = ''.obs;
  
  final body = ''.obs;
  final footer = ''.obs;
  
  final actionType = 'NONE'.obs;
  final buttons = <ButtonState>[].obs;
  
  // Carousel State
  final carouselCards = <CarouselCardState>[
    CarouselCardState(id: '1'),
    CarouselCardState(id: '2'),
  ].obs;
  final activeCardId = '1'.obs;

  // Text Editing Controller for body to manage selection
  final bodyTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    bodyTextController.addListener(() {
      body.value = bodyTextController.text;
    });
  }

  @override
  void onClose() {
    bodyTextController.dispose();
    super.onClose();
  }

  void handleAddVariable(String type) {
    String variableText = "{{}}";
    if (type == "NUMBER") {
      final matches = RegExp(r'\{\{(\d+)\}\}').allMatches(bodyTextController.text);
      int nextIndex = 1;
      if (matches.isNotEmpty) {
        final numbers = matches.map((m) => int.tryParse(m.group(1) ?? '0') ?? 0);
        nextIndex = numbers.reduce((a, b) => a > b ? a : b) + 1;
      }
      variableText = "{{$nextIndex}}";
    }

    final text = bodyTextController.text;
    final selection = bodyTextController.selection;
    if (selection.isValid) {
      final newText = text.replaceRange(selection.start, selection.end, variableText);
      bodyTextController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + variableText.length),
      );
    } else {
      bodyTextController.text = text + variableText;
    }
  }

  int getQuickRepliesCount() => buttons.where((b) => b.type == 'QUICK_REPLY').length;
  int getUrlCount() => buttons.where((b) => b.type == 'URL').length;
  int getPhoneCount() => buttons.where((b) => b.type == 'PHONE_NUMBER').length;

  void handleAddButton(String type) {
    if (type == 'QUICK_REPLY' && getQuickRepliesCount() >= 10) return;
    if (type == 'URL' && getUrlCount() >= 2) return;
    if (type == 'PHONE_NUMBER' && getPhoneCount() >= 1) return;

    buttons.add(ButtonState(type: type, text: ''));
  }

  void handleActionTypeChange(String val) {
    actionType.value = val;
    if (val == "NONE") {
      buttons.clear();
    } else if (val == "CALL_TO_ACTIONS") {
      buttons.removeWhere((b) => b.type == 'QUICK_REPLY');
    } else if (val == "QUICK_REPLIES") {
      buttons.removeWhere((b) => b.type != 'QUICK_REPLY');
    }
  }

  void updateName(String val) {
    name.value = val.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  Future<void> handleCreate() async {
    if (name.value.isEmpty || body.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in required fields', 
        backgroundColor: const Color(0xFFFEF2F2), colorText: const Color(0xFF991B1B));
      return;
    }

    isCreating.value = true;

    try {
      Map<String, dynamic>? headerParam;
      List<Map<String, dynamic>>? cardsParam;

      if (templateType.value == "MEDIA") {
        if (headerType.value == "TEXT" && headerText.value.isNotEmpty) {
          headerParam = {"type": "TEXT", "text": headerText.value};
        } else if (headerType.value != "TEXT" && headerFileUrl.value.isNotEmpty) {
          headerParam = {"type": headerType.value, "handle": headerFileUrl.value};
        }
      } else if (templateType.value == "CAROUSEL") {
        cardsParam = carouselCards.map((c) => {
          "headerType": c.headerType,
          "headerUrl": c.headerUrl,
          "body": c.body,
          "buttons": c.buttons.map((b) => {
            "type": b.type,
            "text": b.text,
            if (b.url != null) "url": b.url,
            if (b.phoneNumber != null) "phone_number": b.phoneNumber,
          }).toList(),
        }).toList();
      }

      final payload = {
        "name": name.value,
        "category": category.value,
        "language": language.value,
        "body": body.value,
        if (footer.value.isNotEmpty) "footer": footer.value,
        "buttons": buttons.map((b) => {
          "type": b.type,
          "text": b.text,
          if (b.url != null) "url": b.url,
          if (b.phoneNumber != null) "phone_number": b.phoneNumber,
        }).toList(),
        if (headerParam != null) "header": headerParam,
        if (cardsParam != null) "cards": cardsParam,
      };

      await _repository.createTemplate(payload);
      
      Get.back();
      Get.snackbar('Success', 'Template submitted successfully!', 
        backgroundColor: const Color(0xFFF0FDF4), colorText: const Color(0xFF166534));
    } catch (e) {
      Get.snackbar('Error', e.toString(), 
        backgroundColor: const Color(0xFFFEF2F2), colorText: const Color(0xFF991B1B));
    } finally {
      isCreating.value = false;
    }
  }
}
