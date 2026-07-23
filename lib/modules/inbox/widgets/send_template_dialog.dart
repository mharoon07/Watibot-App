import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:watibot/core/theme/app_theme.dart';

class SendTemplateDialog extends StatefulWidget {
  final List<Map<String, dynamic>> templates;
  final Function(String templateName, String language, List<String> params, String headerUrl) onSend;

  const SendTemplateDialog({
    super.key,
    required this.templates,
    required this.onSend,
  });

  @override
  State<SendTemplateDialog> createState() => _SendTemplateDialogState();
}

class _SendTemplateDialogState extends State<SendTemplateDialog> {
  Map<String, dynamic>? selectedTemplate;
  String language = 'en_US';
  List<String> templateParams = [];
  String headerMediaUrl = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Choose Template', 
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTemplateSelector(),
                    if (selectedTemplate != null) ...[
                      const SizedBox(height: 24),
                      _buildParameterInputs(),
                      const SizedBox(height: 24),
                      _buildLivePreview(),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: selectedTemplate == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            widget.onSend(
                              selectedTemplate!['name'].toString(),
                              language,
                              templateParams,
                              headerMediaUrl,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Send Template', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Template *', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.primaryColor)),
          ),
          hint: Text('Select Template', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8))),
          value: selectedTemplate?['name']?.toString(),
          items: widget.templates.where((t) => t['status'] == 'APPROVED').map((t) {
            final name = t['name']?.toString() ?? '';
            return DropdownMenuItem(value: name, child: Text(name, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF334155))));
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                selectedTemplate = widget.templates.firstWhere((t) => t['name'] == val);
                if (selectedTemplate != null && selectedTemplate!['language'] != null) {
                  language = selectedTemplate!['language'].toString();
                }
                _initializeParameters();
              });
            }
          },
        ),
      ],
    );
  }

  void _initializeParameters() {
    if (selectedTemplate == null) return;
    
    final components = selectedTemplate!['components'] as List? ?? [];
    final bodyComponent = components.firstWhere((c) => c['type'] == 'BODY', orElse: () => null);
    
    int paramCount = 0;
    if (bodyComponent != null && bodyComponent['text'] != null) {
      final matches = RegExp(r'\{\{\d+\}\}').allMatches(bodyComponent['text'].toString());
      paramCount = matches.length;
      
      final exampleBody = bodyComponent['example']?['body_text'];
      if (exampleBody != null && exampleBody is List && exampleBody.isNotEmpty) {
        final List exampleArr = exampleBody[0] is List ? exampleBody[0] : exampleBody;
        if (exampleArr.length > paramCount) paramCount = exampleArr.length;
      }
    }
    
    templateParams = List.filled(paramCount, '');
    headerMediaUrl = '';
  }

  Widget _buildParameterInputs() {
    final components = selectedTemplate?['components'] as List? ?? [];
    final headerComponent = components.firstWhere((c) => c['type'] == 'HEADER', orElse: () => null);
    
    final List<Widget> inputs = [];
    
    if (headerComponent != null) {
      final format = headerComponent['format']?.toString() ?? '';
      if (['IMAGE', 'VIDEO', 'DOCUMENT'].contains(format)) {
        inputs.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$format URL (Optional)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
              const SizedBox(height: 8),
              TextField(
                onChanged: (val) => setState(() => headerMediaUrl = val),
                decoration: InputDecoration(
                  hintText: 'Enter $format URL',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.primaryColor)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    }

    for (int i = 0; i < templateParams.length; i++) {
      inputs.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('{{${i + 1}}}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
            const SizedBox(height: 8),
            TextField(
              onChanged: (val) => setState(() => templateParams[i] = val),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.primaryColor)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }
    
    if (inputs.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parameters', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        ...inputs,
      ],
    );
  }

  Widget _buildLivePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LIVE PREVIEW', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE5DDD5), // WhatsApp BG color
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBD5E1).withOpacity(0.5)),
            image: const DecorationImage(
              image: AssetImage('assets/images/chat_bg.png'), // Fallback to color if not available
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),
          child: Center(child: _buildBubble()),
        ),
      ],
    );
  }

  Widget _buildBubble() {
    final components = selectedTemplate?['components'] as List? ?? [];
    
    final headerComponent = components.firstWhere((c) => c['type'] == 'HEADER', orElse: () => null);
    final bodyComponent = components.firstWhere((c) => c['type'] == 'BODY', orElse: () => null);
    final footerComponent = components.firstWhere((c) => c['type'] == 'FOOTER', orElse: () => null);
    final buttonsComponent = components.firstWhere((c) => c['type'] == 'BUTTONS', orElse: () => null);

    String headerType = headerComponent?['format']?.toString() ?? 'NONE';
    String headerText = headerComponent?['text']?.toString() ?? '';
    
    String bodyText = bodyComponent?['text']?.toString() ?? '';
    for (int i = 0; i < templateParams.length; i++) {
      final val = templateParams[i].isEmpty ? '{{${i + 1}}}' : templateParams[i];
      bodyText = bodyText.replaceAll('{{${i + 1}}}', val);
    }
    
    String footerText = footerComponent?['text']?.toString() ?? '';
    List<dynamic> buttons = buttonsComponent?['buttons'] as List? ?? [];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12), 
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerType == 'TEXT' && headerText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text(
                headerText,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF111B21)),
              ),
            ),
          
          if (['IMAGE', 'VIDEO', 'DOCUMENT'].contains(headerType))
            Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: const Color(0xFFF0F2F5),
                  child: headerMediaUrl.isNotEmpty
                      ? (headerType == 'IMAGE' 
                          ? Image.network(headerMediaUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderIcon(Icons.image))
                          : _placeholderIcon(Icons.play_circle_fill))
                      : _placeholderIcon(
                          headerType == 'IMAGE' ? Icons.image :
                          headerType == 'VIDEO' ? Icons.play_circle_fill : Icons.picture_as_pdf
                        ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              bodyText.isEmpty ? 'Message body' : bodyText,
              style: GoogleFonts.inter(fontSize: 14, height: 1.3, color: const Color(0xFF111B21)),
            ),
          ),

          if (footerText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6),
              child: Text(
                footerText,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF667781)),
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 6),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '12:00 PM',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF667781)),
              ),
            ),
          ),

          if (buttons.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFF0F2F5)),
            ...buttons.map((btn) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF0F2F5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    btn['type'] == 'URL' ? Icons.open_in_new :
                    btn['type'] == 'PHONE_NUMBER' ? Icons.phone : Icons.reply,
                    size: 16,
                    color: const Color(0xFF00A884),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    btn['text']?.toString() ?? 'Button',
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF00A884)),
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
      child: Icon(icon, size: 40, color: const Color(0xFF8696A0)),
    );
  }
}
