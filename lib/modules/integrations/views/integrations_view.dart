import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/integrations/controllers/integrations_controller.dart';
import 'package:watibot/modules/integrations/models/integration_model.dart';
import 'package:watibot/modules/integrations/views/integration_automation_view.dart';




class IntegrationsView extends GetView<IntegrationsController> {
  const IntegrationsView({super.key});

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
          'E-Commerce Integrations',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchIntegrations,
        color: const Color(0xFF00B074),
        child: CustomScrollView(
          slivers: [
            // Overview Metrics Row
            SliverToBoxAdapter(
              child: Obx(() {
                final sh = controller.shopify.value;
                final woo = controller.woocommerce.value;

                final connectedCount = (sh?.connected == true ? 1 : 0) + (woo?.connected == true ? 1 : 0);
                final totalOrders = (sh?.orders.length ?? 0) + (woo?.orders.length ?? 0);
                final totalProducts = (sh?.products.length ?? 0) + (woo?.products.length ?? 0);

                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricTile('Connected Stores', '$connectedCount / 2', Icons.storefront_outlined, const Color(0xFF00B074)),
                      Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
                      _buildMetricTile('Synced Orders', '$totalOrders', Icons.shopping_bag_outlined, const Color(0xFF3B82F6)),
                      Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
                      _buildMetricTile('Products', '$totalProducts', Icons.inventory_2_outlined, const Color(0xFF8B5CF6)),
                    ],
                  ),
                );
              }),
            ),

            // Tab Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() => Row(
                  children: [
                    _buildTabChip('overview', 'All Platforms'),
                    const SizedBox(width: 8),
                    _buildTabChip('shopify', 'Shopify'),
                    const SizedBox(width: 8),
                    _buildTabChip('woocommerce', 'WooCommerce'),
                  ],
                )),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Integrations Body Content
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B074)),
                  ),
                );
              }

              final tab = controller.selectedTab.value;
              final sh = controller.shopify.value;
              final woo = controller.woocommerce.value;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (tab == 'overview' || tab == 'shopify')
                      _buildShopifyCard(context, sh),
                    if (tab == 'overview') const SizedBox(height: 16),
                    if (tab == 'overview' || tab == 'woocommerce')
                      _buildWooCommerceCard(context, woo),
                  ]),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildTabChip(String key, String label) {
    final isSelected = controller.selectedTab.value == key;
    return InkWell(
      onTap: () => controller.onTabChanged(key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B074).withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF00B074) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF00B074) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildShopifyCard(BuildContext context, ShopifyIntegrationModel? item) {
    final isConnected = item?.connected == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isConnected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF96BF48).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shopping_bag, color: Color(0xFF96BF48), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shopify Integration',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isConnected ? (item?.storeUrl ?? 'Store Connected') : 'Connect your Shopify store',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(isConnected),
            ],
          ),
          const Divider(height: 24),

          if (isConnected) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Automation:', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                Text(
                  item?.orderAutomationEnabled == true ? 'Enabled' : 'Disabled',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: item?.orderAutomationEnabled == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Synced Orders:', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                Text('${item?.orders.length ?? 0}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const IntegrationAutomationView(), arguments: 'shopify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B074),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Configure',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
                  onPressed: () => _showShopifySheet(context, item),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => _confirmDisconnect(context, 'Shopify', controller.disconnectShopify),
                  child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),

          ] else ...[
            Text(
              'Sync Shopify orders, customer details, and automated WhatsApp notifications.',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showShopifySheet(context, item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF96BF48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Connect Shopify Store', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWooCommerceCard(BuildContext context, WooCommerceIntegrationModel? item) {
    final isConnected = item?.connected == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isConnected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7F54B3).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.store, color: Color(0xFF7F54B3), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WooCommerce Integration',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isConnected ? (item?.storeUrl ?? 'Store Connected') : 'Connect your WooCommerce store',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(isConnected),
            ],
          ),
          const Divider(height: 24),

          if (isConnected) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Automation:', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                Text(
                  item?.orderAutomationEnabled == true ? 'Enabled' : 'Disabled',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: item?.orderAutomationEnabled == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Synced Orders:', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                Text('${item?.orders.length ?? 0}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const IntegrationAutomationView(), arguments: 'woocommerce'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B074),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Configure',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
                  onPressed: () => _showWooCommerceSheet(context, item),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => _confirmDisconnect(context, 'WooCommerce', controller.disconnectWooCommerce),
                  child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),

          ] else ...[
            Text(
              'Sync WooCommerce REST API consumer keys & webhook events for WhatsApp automation.',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showWooCommerceSheet(context, item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F54B3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Connect WooCommerce Store', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusPill(bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isConnected ? 'Connected' : 'Available',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isConnected ? const Color(0xFF10B981) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  void _showShopifySheet(BuildContext context, ShopifyIntegrationModel? item) {
    final urlCtrl = TextEditingController(text: item?.storeUrl ?? '');
    final tokenCtrl = TextEditingController(text: item?.accessToken ?? '');
    bool autoEnabled = item?.orderAutomationEnabled ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure Shopify Integration',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: urlCtrl,
                    decoration: InputDecoration(
                      labelText: 'Store URL (e.g. my-store.myshopify.com) *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tokenCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Admin API Access Token',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () async {
                              if (urlCtrl.text.isEmpty) {
                                Get.snackbar('Required', 'Please enter store URL');
                                return;
                              }

                              final success = await controller.saveShopifyConfig(
                                storeUrl: urlCtrl.text,
                                accessToken: tokenCtrl.text,
                                orderAutomationEnabled: autoEnabled,
                              );

                              if (success) Get.back();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isSaving.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Save Configuration', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    )),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showWooCommerceSheet(BuildContext context, WooCommerceIntegrationModel? item) {
    final urlCtrl = TextEditingController(text: item?.storeUrl ?? '');
    final keyCtrl = TextEditingController(text: item?.consumerKey ?? '');
    final secretCtrl = TextEditingController(text: item?.consumerSecret ?? '');
    bool autoEnabled = item?.orderAutomationEnabled ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure WooCommerce Integration',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: urlCtrl,
                    decoration: InputDecoration(
                      labelText: 'Store URL (e.g. https://my-woo-store.com) *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keyCtrl,
                    decoration: InputDecoration(
                      labelText: 'Consumer Key (ck_...)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: secretCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Consumer Secret (cs_...)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () async {
                              if (urlCtrl.text.isEmpty) {
                                Get.snackbar('Required', 'Please enter store URL');
                                return;
                              }

                              final success = await controller.saveWooCommerceConfig(
                                storeUrl: urlCtrl.text,
                                consumerKey: keyCtrl.text,
                                consumerSecret: secretCtrl.text,
                                orderAutomationEnabled: autoEnabled,
                              );

                              if (success) Get.back();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isSaving.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Save Configuration', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    )),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDisconnect(BuildContext context, String platform, Future<bool> Function() onDisconnect) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Disconnect $platform?'),
        content: Text('Are you sure you want to disconnect $platform from your workspace?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await onDisconnect();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Disconnect', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
