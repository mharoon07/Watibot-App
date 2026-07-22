import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/modules/integrations/controllers/integrations_controller.dart';
import 'package:watibot/modules/integrations/views/integration_automation_view.dart';


class IntegrationDetailsView extends GetView<IntegrationsController> {
  const IntegrationDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final String platform = Get.arguments as String; // 'shopify' or 'woocommerce'
    final isShopify = platform == 'shopify';

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
          isShopify ? 'Shopify Integration' : 'WooCommerce Integration',
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
            onPressed: controller.fetchIntegrations,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00B074)),
          );
        }

        final sh = controller.shopify.value;
        final woo = controller.woocommerce.value;

        final isConnected = isShopify ? (sh?.connected == true) : (woo?.connected == true);
        final storeUrl = isShopify ? sh?.storeUrl : woo?.storeUrl;
        final orders = isShopify ? (sh?.orders ?? []) : (woo?.orders ?? []);
        final products = isShopify ? (sh?.products ?? []) : (woo?.products ?? []);

        return SingleChildScrollView(

          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Header Banner Card
              Container(
                width: double.infinity,
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
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isShopify
                          ? const Color(0xFF96BF48).withValues(alpha: 0.15)
                          : const Color(0xFF7F54B3).withValues(alpha: 0.15),
                      child: Icon(
                        isShopify ? Icons.shopping_bag : Icons.store,
                        color: isShopify ? const Color(0xFF96BF48) : const Color(0xFF7F54B3),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isShopify ? 'Shopify Store' : 'WooCommerce Store',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      storeUrl ?? 'Not Connected',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConnected ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isConnected ? 'Active & Connected' : 'Disconnected',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBox('Synced Orders', '${orders.length}', Icons.shopping_cart_outlined, const Color(0xFF3B82F6)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBox('Synced Products', '${products.length}', Icons.inventory_2_outlined, const Color(0xFF8B5CF6)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Automation Control Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Automation Settings (8)',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              ),
                              Text(
                                'Full template & delay controls',
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => Get.to(() => const IntegrationAutomationView(), arguments: platform),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B074),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.settings_suggest, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'Manage',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),


                      ],
                    ),
                    const Divider(height: 20),

                    _buildAutomationTile(
                      platform: platform,
                      isConnected: isConnected,
                      automationMap: isShopify ? (sh?.automation ?? {}) : (woo?.automation ?? {}),
                      id: 'order_confirmation',
                      title: 'Order Confirmation',
                      subtitle: 'Send WhatsApp message when a new order is placed.',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF10B981),
                    ),
                    _buildAutomationTile(
                      platform: platform,
                      isConnected: isConnected,
                      automationMap: isShopify ? (sh?.automation ?? {}) : (woo?.automation ?? {}),
                      id: 'order_fulfillment',
                      title: 'Order Fulfillment',
                      subtitle: 'Notify customer when order is shipped or fulfilled.',
                      icon: Icons.local_shipping_outlined,
                      color: const Color(0xFF3B82F6),
                    ),
                    _buildAutomationTile(
                      platform: platform,
                      isConnected: isConnected,
                      automationMap: isShopify ? (sh?.automation ?? {}) : (woo?.automation ?? {}),
                      id: 'order_cancellation',
                      title: 'Order Cancellation',
                      subtitle: 'Alert customer when order is cancelled or refunded.',
                      icon: Icons.cancel_outlined,
                      color: const Color(0xFFEF4444),
                    ),
                    _buildAutomationTile(
                      platform: platform,
                      isConnected: isConnected,
                      automationMap: isShopify ? (sh?.automation ?? {}) : (woo?.automation ?? {}),
                      id: 'order_notification',
                      title: 'Order Notification',
                      subtitle: 'General order status updates to customer.',
                      icon: Icons.notifications_none_outlined,
                      color: const Color(0xFFF59E0B),
                    ),
                    _buildAutomationTile(
                      platform: platform,
                      isConnected: isConnected,
                      automationMap: isShopify ? (sh?.automation ?? {}) : (woo?.automation ?? {}),
                      id: 'admin_notification',
                      title: 'Admin Notification',
                      subtitle: 'Notify admin/store owner on new orders.',
                      icon: Icons.admin_panel_settings_outlined,
                      color: const Color(0xFF8B5CF6),
                    ),
                    _buildAutomationTile(
                      platform: platform,
                      isConnected: isConnected,
                      automationMap: isShopify ? (sh?.automation ?? {}) : (woo?.automation ?? {}),
                      id: 'abandoned_checkout',
                      title: 'Abandoned Checkout',
                      subtitle: 'Recover abandoned carts via WhatsApp.',
                      icon: Icons.remove_shopping_cart_outlined,
                      color: const Color(0xFFEC4899),
                    ),
                    _buildAutomationTile(
                      platform: platform,
                      isConnected: isConnected,
                      automationMap: isShopify ? (sh?.automation ?? {}) : (woo?.automation ?? {}),
                      id: 'draft_order_recovery',
                      title: 'Draft Order Recovery',
                      subtitle: 'Follow up on draft orders with payment link.',
                      icon: Icons.mark_as_unread_outlined,
                      color: const Color(0xFF6366F1),
                    ),
                    _buildAutomationTile(
                      platform: platform,
                      isConnected: isConnected,
                      automationMap: isShopify ? (sh?.automation ?? {}) : (woo?.automation ?? {}),
                      id: 'rewind',
                      title: 'Rewind / Auto-Reply',
                      subtitle: 'Schedule or delay messages to be sent to users at a specified time.',
                      icon: Icons.history_toggle_off_outlined,
                      color: const Color(0xFF14B8A6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Synced Orders Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Orders (${orders.length})',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        Text(
                          'Live Sync',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00B074)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    if (orders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text('No orders synced yet', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13)),
                        ),
                      )
                    else
                      Column(
                        children: orders.take(5).map((order) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                  child: const Icon(Icons.receipt, color: Color(0xFF3B82F6), size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Order #${order.orderNumber ?? order.externalOrderId ?? order.id}',
                                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        order.customerEmail ?? order.customerPhone ?? 'Customer',
                                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${order.currency} ${order.totalPrice ?? "0.00"}',
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF00B074)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      order.status ?? 'Paid',
                                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Synced Products Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Synced Products (${products.length})',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    const Divider(height: 20),
                    if (products.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text('No products synced yet', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13)),
                        ),
                      )
                    else
                      Column(
                        children: products.take(5).map((product) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                  child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF8B5CF6), size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (product.sku != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'SKU: ${product.sku}',
                                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Text(
                                  '${product.currency} ${product.price}',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAutomationTile({
    required String platform,
    required bool isConnected,
    required Map<String, dynamic> automationMap,
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final moduleData = automationMap[id];
    final bool isActive = (moduleData is Map && moduleData['active'] == true);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeColor: color,
            onChanged: isConnected
                ? (val) {
                    controller.updateAutomationModule(platform, id, {'active': val});
                  }
                : null,
          ),

        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon, Color color) {

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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
