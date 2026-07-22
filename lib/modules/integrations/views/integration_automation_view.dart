import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/integrations/controllers/integrations_controller.dart';

class IntegrationAutomationView extends GetView<IntegrationsController> {
  const IntegrationAutomationView({super.key});

  static const List<Map<String, String>> variableOptions = [
    {'label': 'Customer First Name', 'value': 'customer.first_name'},
    {'label': 'Customer Last Name', 'value': 'customer.last_name'},
    {'label': 'Order Number', 'value': 'order_number'},
    {'label': 'Total Price', 'value': 'total_price'},
    {'label': 'Currency', 'value': 'currency'},
    {'label': 'Shop URL', 'value': 'shop_url'},
    {'label': 'Customer Phone', 'value': 'customer.phone'},
    {'label': 'Shipping City', 'value': 'shipping_address.city'},
    {'label': 'Shipping Country', 'value': 'shipping_address.country'},
    {'label': 'Payment Status', 'value': 'financial_status'},
    {'label': 'Payment Method', 'value': 'payment_method'},
    {'label': 'Fulfillment Status', 'value': 'fulfillment_status'},
  ];

  static const List<Map<String, String>> modulesList = [
    {'id': 'order_confirmation', 'title': 'Order Confirmation', 'desc': 'Send WhatsApp message when a new order is placed.'},
    {'id': 'order_fulfillment', 'title': 'Order Fulfillment', 'desc': 'Notify customer when order is shipped or fulfilled.'},
    {'id': 'order_cancellation', 'title': 'Order Cancellation', 'desc': 'Alert customer when order is cancelled or refunded.'},
    {'id': 'order_notification', 'title': 'Order Notification', 'desc': 'General order status updates to customer.'},
    {'id': 'admin_notification', 'title': 'Admin Notification', 'desc': 'Notify admin/store owner on new orders.'},
    {'id': 'abandoned_checkout', 'title': 'Abandoned Checkout', 'desc': 'Recover abandoned carts via WhatsApp.'},
    {'id': 'draft_order_recovery', 'title': 'Draft Order Recovery', 'desc': 'Follow up on draft orders with payment link.'},
    {'id': 'rewind', 'title': 'Rewind / Auto-Reply', 'desc': 'Schedule or delay messages to be sent to users at a specified time.'},
  ];

  @override
  Widget build(BuildContext context) {
    final String platform = (Get.arguments as String?) ?? 'shopify';
    final isShopify = platform == 'shopify';

    // Fetch templates on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.availableTemplates.isEmpty) {
        controller.fetchTemplates();
      }
    });

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
          isShopify ? 'Shopify Automations' : 'WooCommerce Automations',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00B074)),
            onPressed: () {
              controller.fetchIntegrations();
              controller.fetchTemplates();
            },
          ),
        ],
      ),
      body: Obx(() {
        final sh = controller.shopify.value;
        final woo = controller.woocommerce.value;

        final isConnected = isShopify ? (sh?.connected == true) : (woo?.connected == true);
        final storeUrl = isShopify ? sh?.storeUrl : woo?.storeUrl;
        final automationMap = isShopify ? (sh?.automation ?? {}) : (woo?.automation ?? {});
        final autoEnabled = isShopify ? (sh?.orderAutomationEnabled == true) : (woo?.orderAutomationEnabled == true);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B074).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt, color: Color(0xFF00B074), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Master Order Automations',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                          ),
                          Text(
                            storeUrl ?? 'Store Connected',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: autoEnabled,
                      activeColor: const Color(0xFF00B074),
                      onChanged: isConnected
                          ? (val) {
                              if (isShopify) {
                                controller.saveShopifyConfig(storeUrl: storeUrl!, orderAutomationEnabled: val);
                              } else {
                                controller.saveWooCommerceConfig(storeUrl: storeUrl!, orderAutomationEnabled: val);
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Configure Automation Triggers (8)',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),

              // Modules List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modulesList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final moduleDef = modulesList[index];
                  final String moduleId = moduleDef['id']!;
                  final moduleConfig = (automationMap[moduleId] is Map)
                      ? Map<String, dynamic>.from(automationMap[moduleId])
                      : <String, dynamic>{};

                  return _AutomationModuleCard(
                    platform: platform,
                    isConnected: isConnected,
                    moduleId: moduleId,
                    title: moduleDef['title']!,
                    desc: moduleDef['desc']!,
                    initialConfig: moduleConfig,
                    templates: controller.availableTemplates,
                    onSave: (updatedConfig) {
                      controller.updateAutomationModule(platform, moduleId, updatedConfig);
                    },
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _AutomationModuleCard extends StatefulWidget {
  final String platform;
  final bool isConnected;
  final String moduleId;
  final String title;
  final String desc;
  final Map<String, dynamic> initialConfig;
  final List<String> templates;
  final Function(Map<String, dynamic>) onSave;

  const _AutomationModuleCard({
    required this.platform,
    required this.isConnected,
    required this.moduleId,
    required this.title,
    required this.desc,
    required this.initialConfig,
    required this.templates,
    required this.onSave,
  });

  @override
  State<_AutomationModuleCard> createState() => _AutomationModuleCardState();
}

class _AutomationModuleCardState extends State<_AutomationModuleCard> {
  final controller = Get.find<IntegrationsController>();
  late bool isActive;

  late TextEditingController templateController;
  late TextEditingController languageController;
  late TextEditingController delayController;
  late TextEditingController adminPhoneController;
  late String delayUnit;
  late Map<String, String> varMappings;

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadFromConfig(widget.initialConfig);
  }

  @override
  void didUpdateWidget(covariant _AutomationModuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialConfig != widget.initialConfig) {
      _loadFromConfig(widget.initialConfig);
    }
  }

  void _loadFromConfig(Map<String, dynamic> cfg) {
    isActive = cfg['active'] == true;
    templateController = TextEditingController(text: cfg['template']?.toString() ?? '');
    languageController = TextEditingController(text: cfg['language']?.toString() ?? 'en_US');
    delayController = TextEditingController(text: (cfg['delaySeconds'] ?? cfg['delay'] ?? 0).toString());
    adminPhoneController = TextEditingController(text: cfg['adminPhone']?.toString() ?? '');
    delayUnit = cfg['delayUnit']?.toString() ?? 'seconds';

    final rawMappings = cfg['variableMappings'] ?? cfg['mappings'];
    varMappings = {};
    if (rawMappings is Map) {
      rawMappings.forEach((key, value) {
        varMappings[key.toString()] = value.toString();
      });
    }
    if (!varMappings.containsKey('1')) varMappings['1'] = 'customer.first_name';
    if (!varMappings.containsKey('2')) varMappings['2'] = 'order_number';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header Row
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              widget.title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            subtitle: Text(
              widget.desc,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isActive,
                  activeColor: const Color(0xFF00B074),
                  onChanged: widget.isConnected
                      ? (val) {
                          setState(() => isActive = val);
                          _handleSave();
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                  onPressed: () => setState(() => isExpanded = !isExpanded),
                ),
              ],
            ),
          ),

          // Expanded Details & Controls
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message Template Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Message Template Name', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                      Obx(() => controller.isLoadingTemplates.value
                          ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00B074)))
                          : const SizedBox.shrink()),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    final templatesList = controller.availableTemplates;
                    final String currentText = templateController.text.trim();
                    final bool hasMatch = templatesList.contains(currentText);

                    if (templatesList.isNotEmpty) {
                      return DropdownButtonFormField<String>(
                        initialValue: hasMatch ? currentText : null,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        ),
                        hint: Text(currentText.isNotEmpty ? currentText : 'Select WhatsApp Template', style: GoogleFonts.inter(fontSize: 12)),
                        items: templatesList
                            .map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => templateController.text = val);
                            final matchObj = controller.templateObjects.firstWhereOrNull((obj) => obj['name'] == val);
                            if (matchObj != null && matchObj['language'] != null) {
                              setState(() => languageController.text = matchObj['language'].toString());
                            }
                          }
                        },
                      );
                    } else {
                      return TextField(
                        controller: templateController,
                        style: GoogleFonts.inter(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'e.g. order_confirmation',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  }),

                  const SizedBox(height: 12),

                  // Language
                  Text('Template Language Code', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: languageController,
                    style: GoogleFonts.inter(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'en_US or en',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Delay Settings
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delay Amount', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            TextField(
                              controller: delayController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: '0',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delay Unit', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: delayUnit,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: ['seconds', 'minutes', 'hours', 'days']
                                  .map((u) => DropdownMenuItem(value: u, child: Text(u, style: GoogleFonts.inter(fontSize: 12))))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => delayUnit = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Admin Phone Number (if admin_notification)
                  if (widget.moduleId == 'admin_notification') ...[
                    Text('Admin Phone Number', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: adminPhoneController,
                      style: GoogleFonts.inter(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: '+923001234567',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Variable Mappings
                  Text('Variable Mappings', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  _buildVariableRow('{{1}}', '1'),
                  const SizedBox(height: 6),
                  _buildVariableRow('{{2}}', '2'),
                  const SizedBox(height: 16),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Save Configuration', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariableRow(String placeholder, String key) {
    return Row(
      children: [
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(placeholder, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: IntegrationAutomationView.variableOptions.any((o) => o['value'] == varMappings[key])
                ? varMappings[key]
                : 'customer.first_name',
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: IntegrationAutomationView.variableOptions
                .map((o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!, style: GoogleFonts.inter(fontSize: 12))))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => varMappings[key] = val);
              }
            },
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    final Map<String, dynamic> updatedConfig = {
      'active': isActive,
      'template': templateController.text.trim(),
      'language': languageController.text.trim(),
      'delaySeconds': int.tryParse(delayController.text.trim()) ?? 0,
      'delayUnit': delayUnit,
      'variableMappings': varMappings,
      if (widget.moduleId == 'admin_notification') 'adminPhone': adminPhoneController.text.trim(),
    };

    widget.onSave(updatedConfig);
  }
}
