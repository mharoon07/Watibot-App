import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/templates/controllers/templates_controller.dart';

class CreateTemplateView extends StatefulWidget {
  const CreateTemplateView({super.key});

  @override
  State<CreateTemplateView> createState() => _CreateTemplateViewState();
}

class _CreateTemplateViewState extends State<CreateTemplateView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bodyController = TextEditingController();
  final _footerController = TextEditingController();
  
  String _category = 'MARKETING';
  final String _language = 'en_US';


  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TemplatesController>();

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
          'Create Template',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template Name
              Text(
                'Template Name',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a template name' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. order_confirmation',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              Text(
                'Category',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _category,
                onChanged: (val) => setState(() => _category = val ?? 'MARKETING'),

                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
                items: const [
                  DropdownMenuItem(value: 'MARKETING', child: Text('MARKETING')),
                  DropdownMenuItem(value: 'UTILITY', child: Text('UTILITY')),
                  DropdownMenuItem(value: 'AUTHENTICATION', child: Text('AUTHENTICATION')),
                ],
              ),
              const SizedBox(height: 16),

              // Body Text
              Text(
                'Body Text',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bodyController,
                maxLines: 5,
                validator: (val) => val == null || val.trim().isEmpty ? 'Body text is required' : null,
                decoration: InputDecoration(
                  hintText: 'Enter template body text. Use {{1}}, {{2}} for variables...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 16),

              // Footer Text (Optional)
              Text(
                'Footer Text (Optional)',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _footerController,
                decoration: InputDecoration(
                  hintText: 'e.g. Reply STOP to unsubscribe',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isCreating.value
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final payload = {
                              'name': _nameController.text.trim(),
                              'category': _category,
                              'language': _language,
                              'text': _bodyController.text.trim(),
                              if (_footerController.text.trim().isNotEmpty)
                                'footerText': _footerController.text.trim(),
                            };
                            try {
                              controller.isCreating.value = true;
                              await controller.createTemplate(payload);
                              Get.back();
                              Get.snackbar(
                                'Success',
                                'Template submitted for approval successfully!',
                                backgroundColor: const Color(0xFF00B074),
                                colorText: Colors.white,
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                e.toString(),
                                backgroundColor: const Color(0xFFEF4444),
                                colorText: Colors.white,
                              );
                            } finally {
                              controller.isCreating.value = false;
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B074),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Submit Template',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
