import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/templates/controllers/create_template_controller.dart';

class WhatsAppTemplatePreview extends StatelessWidget {
  const WhatsAppTemplatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateTemplateController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MESSAGING PREVIEW',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Live Preview',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7DF), // WhatsApp BG color
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1).withOpacity(0.5)),
          ),
          child: Obx(() {
            if (controller.templateType.value == 'CAROUSEL') {
              if (controller.carouselCards.isEmpty) {
                return _buildEmptyBubble();
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.carouselCards.map((card) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildBubble(
                        headerType: card.headerType,
                        headerUrl: card.headerUrl,
                        bodyText: card.body,
                        buttons: card.buttons,
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              return _buildBubble(
                headerType: controller.templateType.value == 'MEDIA' ? controller.headerType.value : 'NONE',
                headerText: controller.headerText.value,
                headerUrl: controller.headerFileUrl.value,
                bodyText: controller.body.value,
                footerText: controller.footer.value,
                buttons: controller.buttons.toList(),
              );
            }
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        'Your message content will appear here...',
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildBubble({
    required String headerType,
    String? headerText,
    String? headerUrl,
    required String bodyText,
    String? footerText,
    required List<ButtonState> buttons,
  }) {
    return Container(
      width: 280, // Fixed width for carousel consistency
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (headerType == 'TEXT' && headerText != null && headerText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Text(
                headerText,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
            ),
          
          if (headerType != 'TEXT' && headerType != 'NONE' && headerUrl != null && headerUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: headerType == 'IMAGE'
                      ? Image.network(headerUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderIcon(Icons.image))
                      : headerType == 'VIDEO'
                          ? _placeholderIcon(Icons.play_circle_fill)
                          : headerType == 'DOCUMENT'
                              ? _placeholderIcon(Icons.picture_as_pdf)
                              : _placeholderIcon(Icons.audiotrack),
                ),
              ),
            ),

          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              bodyText.isEmpty ? 'Your message content will appear here...' : bodyText,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.45,
                color: bodyText.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
              ),
            ),
          ),

          // Footer
          if (footerText != null && footerText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
              child: Text(
                footerText,
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
              ),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 8),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '12:45 PM',
                style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
              ),
            ),
          ),

          // Buttons
          if (buttons.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ...buttons.map((btn) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    btn.type == 'URL'
                        ? Icons.open_in_new
                        : btn.type == 'PHONE_NUMBER'
                            ? Icons.phone
                            : Icons.reply,
                    size: 14,
                    color: const Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    btn.text.isEmpty ? 'Button' : btn.text,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _placeholderIcon(IconData icon) {
    return Center(
      child: Icon(icon, size: 40, color: const Color(0xFF94A3B8)),
    );
  }
}
