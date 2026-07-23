import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/templates/controllers/create_template_controller.dart';
import 'package:watibot/modules/templates/views/widgets/whatsapp_template_preview.dart';
import 'package:watibot/modules/media_library/views/widgets/media_library_modal.dart';

class CreateTemplateView extends GetView<CreateTemplateController> {
  const CreateTemplateView({super.key});

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
        title: Text(
          'New Template Message',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          if (isLargeScreen) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildForm(context),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: const WhatsAppTemplatePreview(),
                  ),
                ),
              ],
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildForm(context),
                const SizedBox(height: 32),
                const WhatsAppTemplatePreview(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Template Category', 'Your template should fall under one of these categories.'),
        Obx(() => _buildDropdown<String>(
          value: controller.category.value,
          items: const [
            DropdownMenuItem(value: 'MARKETING', child: Text('Marketing')),
            DropdownMenuItem(value: 'UTILITY', child: Text('Utility')),
            DropdownMenuItem(value: 'AUTHENTICATION', child: Text('Authentication')),
          ],
          onChanged: (val) => controller.category.value = val!,
        )),
        const SizedBox(height: 20),

        _buildSectionHeader('Template Language', 'The language in which message template is submitted.'),
        Obx(() => _buildDropdown<String>(
          value: controller.language.value,
          items: const [
            DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
            DropdownMenuItem(value: 'es_ES', child: Text('Spanish (Spain)')),
            DropdownMenuItem(value: 'pt_BR', child: Text('Portuguese (BR)')),
            DropdownMenuItem(value: 'ar', child: Text('Arabic')),
          ],
          onChanged: (val) => controller.language.value = val!,
        )),
        const SizedBox(height: 20),

        _buildSectionHeader('Template Name', 'Name can only be lowercase alphanumeric and underscores.'),
        TextFormField(
          initialValue: controller.name.value,
          onChanged: controller.updateName,
          decoration: _inputDecoration('Enter name'),
        ),
        const SizedBox(height: 20),

        _buildSectionHeader('Template Type', 'Your template type should fall under one of these categories.'),
        Obx(() => _buildDropdown<String>(
          value: controller.templateType.value,
          items: const [
            DropdownMenuItem(value: 'STANDARD', child: Text('Standard (Text Only)')),
            DropdownMenuItem(value: 'MEDIA', child: Text('Media / Header Option')),
            DropdownMenuItem(value: 'CAROUSEL', child: Text('Carousel')),
          ],
          onChanged: (val) {
            controller.templateType.value = val!;
            if (val == 'MEDIA' && controller.headerType.value == '') {
              controller.headerType.value = 'TEXT';
            }
          },
        )),
        const SizedBox(height: 20),

        Obx(() {
          if (controller.templateType.value == 'MEDIA') {
            return _buildMediaSettings(context);
          } else if (controller.templateType.value == 'CAROUSEL') {
            return _buildCarouselSettings(context);
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 20),

        _buildSectionHeader('Template Format', 'Use text formatting - *bold* , _italic_ & ~strikethrough~'),
        Stack(
          children: [
            TextFormField(
              controller: controller.bodyTextController,
              maxLines: 5,
              maxLength: 1024,
              decoration: _inputDecoration('Enter your message in here...').copyWith(
                contentPadding: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 40),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 12,
              child: PopupMenuButton<String>(
                onSelected: controller.handleAddVariable,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 14, color: Color(0xFF00B074)),
                      const SizedBox(width: 4),
                      Text('Add Variable', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'NAME', child: Text('Name')),
                  const PopupMenuItem(value: 'NUMBER', child: Text('Number')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSectionHeader('Template Footer (Optional)', 'Your message footer content. Upto 60 characters.'),
        TextFormField(
          initialValue: controller.footer.value,
          maxLength: 60,
          onChanged: (v) => controller.footer.value = v,
          decoration: _inputDecoration('Enter footer text here'),
        ),
        const SizedBox(height: 20),

        _buildInteractiveActions(),
        const SizedBox(height: 32),

        Obx(() => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: (controller.isCreating.value || controller.name.value.isEmpty || controller.body.value.isEmpty)
                ? null
                : controller.handleCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004f46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: controller.isCreating.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Submit', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        )),
      ],
    );
  }

  Widget _buildMediaSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Header Type', null),
          Obx(() => _buildDropdown<String>(
            value: controller.headerType.value,
            items: const [
              DropdownMenuItem(value: 'TEXT', child: Text('Text Header')),
              DropdownMenuItem(value: 'IMAGE', child: Text('Image Header')),
              DropdownMenuItem(value: 'VIDEO', child: Text('Video Header')),
              DropdownMenuItem(value: 'DOCUMENT', child: Text('Document Header')),
              DropdownMenuItem(value: 'AUDIO', child: Text('Audio Header')),
            ],
            onChanged: (val) => controller.headerType.value = val!,
          )),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.headerType.value == 'TEXT') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Header Text', null),
                  TextFormField(
                    initialValue: controller.headerText.value,
                    maxLength: 60,
                    onChanged: (v) => controller.headerText.value = v,
                    decoration: _inputDecoration('Enter header text (e.g. Welcome)'),
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Header URL', null),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: controller.headerFileUrl.value,
                          onChanged: (v) => controller.headerFileUrl.value = v,
                          decoration: _inputDecoration('Enter public URL'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => FractionallySizedBox(
                              heightFactor: 0.9,
                              child: MediaLibraryModal(
                                initialType: controller.headerType.value,
                                onSelect: (url, name) {
                                  controller.headerFileUrl.value = url;
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Library'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    ],
                  ),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildCarouselSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text('Carousel Cards (${controller.carouselCards.length}/10)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13))),
              Obx(() => OutlinedButton.icon(
                onPressed: controller.carouselCards.length < 10 ? () {
                  controller.carouselCards.add(CarouselCardState(id: DateTime.now().millisecondsSinceEpoch.toString()));
                  controller.activeCardId.value = controller.carouselCards.last.id;
                } : null,
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add Card', style: TextStyle(fontSize: 12)),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.carouselCards.asMap().entries.map((entry) {
                final idx = entry.key;
                final card = entry.value;
                final isActive = controller.activeCardId.value == card.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Card ${idx + 1}'),
                    selected: isActive,
                    onSelected: (_) => controller.activeCardId.value = card.id,
                    selectedColor: const Color(0xFF00B074),
                    labelStyle: TextStyle(color: isActive ? Colors.white : Colors.black87),
                  ),
                );
              }).toList(),
            ),
          )),
          const SizedBox(height: 16),
          Obx(() {
            final activeCard = controller.carouselCards.firstWhereOrNull((c) => c.id == controller.activeCardId.value);
            if (activeCard == null) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Editing Card', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                    if (controller.carouselCards.length > 2)
                      TextButton.icon(
                        onPressed: () {
                          controller.carouselCards.remove(activeCard);
                          controller.activeCardId.value = controller.carouselCards.first.id;
                        },
                        icon: const Icon(Icons.delete, size: 14, color: Colors.red),
                        label: const Text('Remove', style: TextStyle(fontSize: 12, color: Colors.red)),
                      )
                  ],
                ),
                const SizedBox(height: 8),
                _buildSectionHeader('Header Media Type', null),
                _buildDropdown<String>(
                  value: activeCard.headerType,
                  items: const [
                    DropdownMenuItem(value: 'IMAGE', child: Text('Image')),
                    DropdownMenuItem(value: 'VIDEO', child: Text('Video')),
                  ],
                  onChanged: (val) {
                    activeCard.headerType = val!;
                    controller.carouselCards.refresh();
                  },
                ),
                const SizedBox(height: 12),
                _buildSectionHeader('Header URL', null),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: activeCard.headerUrl,
                        onChanged: (v) {
                          activeCard.headerUrl = v;
                          controller.carouselCards.refresh();
                        },
                        decoration: _inputDecoration('Enter public URL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.9,
                            child: MediaLibraryModal(
                              initialType: activeCard.headerType,
                              onSelect: (url, name) {
                                activeCard.headerUrl = url;
                                controller.carouselCards.refresh();
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Library'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                _buildSectionHeader('Card Body Text', null),
                TextFormField(
                  initialValue: activeCard.body,
                  maxLength: 160,
                  maxLines: 3,
                  onChanged: (v) {
                    activeCard.body = v;
                    controller.carouselCards.refresh();
                  },
                  decoration: _inputDecoration('Enter message for this card...'),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Card Buttons', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                    Row(
                      children: [
                        _buildSmallBtn('+ URL', () {
                          if (activeCard.buttons.length < 2) {
                            activeCard.buttons.add(ButtonState(type: 'URL', text: ''));
                            controller.carouselCards.refresh();
                          }
                        }),
                        _buildSmallBtn('+ Phone', () {
                          if (activeCard.buttons.length < 2) {
                            activeCard.buttons.add(ButtonState(type: 'PHONE_NUMBER', text: ''));
                            controller.carouselCards.refresh();
                          }
                        }),
                        _buildSmallBtn('+ QR', () {
                          if (activeCard.buttons.length < 2) {
                            activeCard.buttons.add(ButtonState(type: 'QUICK_REPLY', text: ''));
                            controller.carouselCards.refresh();
                          }
                        }),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                ...activeCard.buttons.asMap().entries.map((entry) {
                  final btnIdx = entry.key;
                  final btn = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: btn.text,
                                onChanged: (v) { btn.text = v; controller.carouselCards.refresh(); },
                                decoration: _inputDecoration('Button Text'),
                              ),
                              if (btn.type == 'URL') ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: btn.url,
                                  onChanged: (v) { btn.url = v; controller.carouselCards.refresh(); },
                                  decoration: _inputDecoration('URL (https://...)'),
                                ),
                              ],
                              if (btn.type == 'PHONE_NUMBER') ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: btn.phoneNumber,
                                  onChanged: (v) { btn.phoneNumber = v; controller.carouselCards.refresh(); },
                                  decoration: _inputDecoration('Phone (+1234567...)'),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          onPressed: () {
                            activeCard.buttons.removeAt(btnIdx);
                            controller.carouselCards.refresh();
                          },
                        )
                      ],
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSmallBtn(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
        child: Text(text, style: const TextStyle(fontSize: 10)),
      ),
    );
  }

  Widget _buildInteractiveActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Interactive Actions', 'You can send actions with your message.'),
        Obx(() => Wrap(
          spacing: 16,
          children: [
            _buildRadio('NONE', 'None'),
            _buildRadio('CALL_TO_ACTIONS', 'Call to Actions'),
            _buildRadio('QUICK_REPLIES', 'Quick Replies'),
            _buildRadio('ALL', 'All'),
          ],
        )),
        Obx(() {
          if (controller.actionType.value == 'NONE') return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (controller.actionType.value == 'ALL' || controller.actionType.value == 'QUICK_REPLIES')
                    _buildAddActionButton('Quick Replies', () => controller.handleAddButton('QUICK_REPLY'), controller.getQuickRepliesCount(), 10),
                  if (controller.actionType.value == 'ALL' || controller.actionType.value == 'CALL_TO_ACTIONS') ...[
                    _buildAddActionButton('URL', () => controller.handleAddButton('URL'), controller.getUrlCount(), 2),
                    _buildAddActionButton('Phone', () => controller.handleAddButton('PHONE_NUMBER'), controller.getPhoneCount(), 1),
                  ]
                ],
              ),
              const SizedBox(height: 16),
              ...controller.buttons.asMap().entries.map((entry) {
                final idx = entry.key;
                final btn = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 80, child: Text(btn.type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: btn.text,
                              onChanged: (v) { btn.text = v; controller.buttons.refresh(); },
                              decoration: _inputDecoration('Button Label'),
                            ),
                            if (btn.type == 'URL') ...[
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: btn.url,
                                onChanged: (v) { btn.url = v; controller.buttons.refresh(); },
                                decoration: _inputDecoration('Website URL'),
                              ),
                            ],
                            if (btn.type == 'PHONE_NUMBER') ...[
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: btn.phoneNumber,
                                onChanged: (v) { btn.phoneNumber = v; controller.buttons.refresh(); },
                                decoration: _inputDecoration('Phone Number'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                        onPressed: () => controller.buttons.removeAt(idx),
                      )
                    ],
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRadio(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: controller.actionType.value,
          onChanged: (v) => controller.handleActionTypeChange(v!),
          activeColor: const Color(0xFF004f46),
        ),
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildAddActionButton(String label, VoidCallback onTap, int current, int max) {
    return OutlinedButton.icon(
      onPressed: current >= max ? null : onTap,
      icon: const Icon(Icons.add, size: 14),
      label: Text('$label ($current/$max)', style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF64748B))),
          ]
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({required T value, required List<DropdownMenuItem<T>> items, required void Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: _inputDecoration(''),
      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF00B074))),
    );
  }
}
