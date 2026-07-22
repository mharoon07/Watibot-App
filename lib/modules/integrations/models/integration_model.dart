class IntegrationOrderModel {
  final String id;
  final String source; // 'shopify' or 'woocommerce'
  final String? externalOrderId;
  final String? orderNumber;
  final String? totalPrice;
  final String? currency;
  final String? customerPhone;
  final String? customerEmail;
  final String? status;
  final String? paymentStatus;
  final String? fulfillmentStatus;
  final int? createdAt;
  final String? createdAtIso;

  IntegrationOrderModel({
    required this.id,
    required this.source,
    this.externalOrderId,
    this.orderNumber,
    this.totalPrice,
    this.currency,
    this.customerPhone,
    this.customerEmail,
    this.status,
    this.paymentStatus,
    this.fulfillmentStatus,
    this.createdAt,
    this.createdAtIso,
  });

  factory IntegrationOrderModel.fromJson(Map<String, dynamic> json) {
    return IntegrationOrderModel(
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? 'shopify',
      externalOrderId: json['external_order_id']?.toString(),
      orderNumber: json['order_number']?.toString(),
      totalPrice: json['total_price']?.toString(),
      currency: json['currency']?.toString() ?? 'USD',
      customerPhone: json['customer_phone']?.toString(),
      customerEmail: json['customer_email']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString(),
      fulfillmentStatus: json['fulfillment_status']?.toString(),
      createdAt: json['created_at'] is int ? json['created_at'] : null,
      createdAtIso: json['created_at_iso']?.toString(),
    );
  }
}

class IntegrationProductModel {
  final String id;
  final String source;
  final String? externalProductId;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final String? imageUrl;
  final String? sku;
  final String status;

  IntegrationProductModel({
    required this.id,
    required this.source,
    this.externalProductId,
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    this.imageUrl,
    this.sku,
    required this.status,
  });

  factory IntegrationProductModel.fromJson(Map<String, dynamic> json) {
    return IntegrationProductModel(
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? 'shopify',
      externalProductId: json['external_product_id']?.toString(),
      name: json['name']?.toString() ?? 'Product',
      description: json['description']?.toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      imageUrl: json['image_url']?.toString(),
      sku: json['sku']?.toString(),
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class ShopifyIntegrationModel {
  final bool connected;
  final String? storeUrl;
  final String? integrationToken;
  final String? accessToken;
  final bool orderAutomationEnabled;
  final String? orderTemplate;
  final String? orderTemplateLanguage;
  final Map<String, dynamic> automation;
  final List<IntegrationOrderModel> orders;
  final List<IntegrationProductModel> products;

  ShopifyIntegrationModel({
    required this.connected,
    this.storeUrl,
    this.integrationToken,
    this.accessToken,
    required this.orderAutomationEnabled,
    this.orderTemplate,
    this.orderTemplateLanguage,
    required this.automation,
    required this.orders,
    required this.products,
  });

  factory ShopifyIntegrationModel.fromJson(Map<String, dynamic> json) {
    return ShopifyIntegrationModel(
      connected: json['connected'] == true,
      storeUrl: json['store_url']?.toString(),
      integrationToken: json['integration_token']?.toString(),
      accessToken: json['access_token']?.toString(),
      orderAutomationEnabled: json['order_automation_enabled'] == true,
      orderTemplate: json['order_template']?.toString(),
      orderTemplateLanguage: json['order_template_language']?.toString(),
      automation: json['automation'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['automation'])
          : <String, dynamic>{},
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => IntegrationOrderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => IntegrationProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WooCommerceIntegrationModel {
  final bool connected;
  final String? storeUrl;
  final String? consumerKey;
  final String? consumerSecret;
  final String? webhookSecret;
  final bool orderAutomationEnabled;
  final Map<String, dynamic> automation;
  final List<IntegrationOrderModel> orders;
  final List<IntegrationProductModel> products;

  WooCommerceIntegrationModel({
    required this.connected,
    this.storeUrl,
    this.consumerKey,
    this.consumerSecret,
    this.webhookSecret,
    required this.orderAutomationEnabled,
    required this.automation,
    required this.orders,
    required this.products,
  });

  factory WooCommerceIntegrationModel.fromJson(Map<String, dynamic> json) {
    return WooCommerceIntegrationModel(
      connected: json['connected'] == true,
      storeUrl: json['store_url']?.toString(),
      consumerKey: json['consumer_key']?.toString(),
      consumerSecret: json['consumer_secret']?.toString(),
      webhookSecret: json['webhook_secret']?.toString(),
      orderAutomationEnabled: json['order_automation_enabled'] == true,
      automation: json['automation'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['automation'])
          : <String, dynamic>{},
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => IntegrationOrderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => IntegrationProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

