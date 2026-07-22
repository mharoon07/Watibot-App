import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/templates/models/template_model.dart';
import 'package:watibot/modules/templates/controllers/templates_controller.dart';

class TemplateDetailsView extends GetView<TemplatesController> {
  final TemplateModel? template;

  const TemplateDetailsView({super.key, this.template});

  @override
  Widget build(BuildContext context) {
    final item = template ?? controller.selectedTemplate.value;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Template Details')),
        body: const Center(child: Text('No template selected')),
      );
    }

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
              item.name,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              '${item.category} • ${item.language}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item.statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: item.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: item.statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WhatsApp Chat Bubble Preview
            _buildWhatsAppPreview(item),
            const SizedBox(height: 24),

            // Variable Test Inputs
            if (item.variableIndices.isNotEmpty) ...[
              _buildVariableInputs(item),
              const SizedBox(height: 24),
            ],

            // Template Metadata Details Card
            _buildMetadataCard(item),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppPreview(TemplateModel item) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chat bubble
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header component
                    if (item.headerComponent != null) _buildHeaderWidget(item.headerComponent!),

                    // Body Text with Dynamic Variables
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Obx(() => Text(
                        _replaceVariables(item.text ?? item.bodyComponent?.text ?? '', controller.detailTestValues),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.45,
                          color: const Color(0xFF1E293B),
                        ),
                      )),
                    ),

                    // Footer component
                    if (item.footerComponent?.text != null && item.footerComponent!.text!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
                        child: Text(
                          item.footerComponent!.text!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),

                    // Timestamp
                    Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 8),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '12:45 PM',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),

                    // Buttons
                    if (item.buttons.isNotEmpty) ...[
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ...item.buttons.map((btn) => Container(
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
                              btn.text,
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderWidget(TemplateComponentModel header) {
    if (header.format == 'IMAGE') {
      String? imgUrl;
      final Map<String, dynamic>? ex = header.example;
      if (ex != null) {
        final dynamic handles = ex['header_handle'] ?? ex['header_url'] ?? ex['header_handle_url'];
        if (handles is List && handles.isNotEmpty) {
          imgUrl = handles.first?.toString();
        } else if (handles is String) {
          imgUrl = handles;
        }
      }


      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
          ),
          image: imgUrl != null && imgUrl.startsWith('http')
              ? DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)
              : null,
        ),
        child: (imgUrl == null || !imgUrl.startsWith('http'))
            ? const Center(child: Icon(Icons.image, size: 40, color: Color(0xFF94A3B8)))
            : null,
      );
    }

    if (header.text != null && header.text!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 14),
        child: Text(
          header.text!,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildVariableInputs(TemplateModel item) {
    final vars = item.variableIndices;
    return Container(
      padding: const EdgeInsets.all(16),
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
              Text(
                'TEST VARIABLES',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: const Color(0xFF64748B),
                ),
              ),
              TextButton(
                onPressed: controller.clearTestValues,
                child: Text(
                  'Clear All',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF00B074)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...vars.map((idx) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Variable {{$idx}}',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 4),
                TextField(
                  onChanged: (val) => controller.setTestValue(idx, val),
                  decoration: InputDecoration(
                    hintText: 'Enter test value for {{$idx}}...',
                    hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    fillColor: const Color(0xFFF8FAFC),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(TemplateModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TEMPLATE INFORMATION',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Template Name', item.name),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('Registry ID', item.id ?? 'Not Synced'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('Category', item.category),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('Language', item.language),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('Status', item.status),
          if (item.rejectedReason != null && item.rejectedReason!.isNotEmpty) ...[
            const Divider(height: 20, color: Color(0xFFF1F5F9)),
            _buildInfoRow('Rejection Reason', item.rejectedReason!, isError: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isError ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  String _replaceVariables(String text, Map<String, String> values) {
    var result = text;
    values.forEach((key, val) {
      if (val.isNotEmpty) {
        result = result.replaceAll('{{$key}}', val);
      }
    });
    return result;
  }
}
