import 'package:get/get.dart';
import 'package:watibot/modules/integrations/models/integration_model.dart';
import 'package:watibot/modules/integrations/repositories/integrations_repository.dart';

class IntegrationsController extends GetxController {
  final IntegrationsRepository _repository = IntegrationsRepository();

  final Rxn<ShopifyIntegrationModel> shopify = Rxn<ShopifyIntegrationModel>();
  final Rxn<WooCommerceIntegrationModel> woocommerce = Rxn<WooCommerceIntegrationModel>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString selectedTab = 'overview'.obs; // 'overview', 'shopify', 'woocommerce'

  @override
  void onInit() {
    super.onInit();
    fetchIntegrations();
  }

  Future<void> fetchIntegrations() async {
    isLoading.value = true;
    final res = await _repository.getIntegrationsData();
    isLoading.value = false;

    if (res['success'] == true) {
      shopify.value = res['shopify'] as ShopifyIntegrationModel?;
      woocommerce.value = res['woocommerce'] as WooCommerceIntegrationModel?;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to load integrations', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void onTabChanged(String tab) {
    selectedTab.value = tab;
  }

  Future<bool> saveShopifyConfig({
    required String storeUrl,
    String? accessToken,
    bool orderAutomationEnabled = true,
  }) async {
    isSaving.value = true;
    final payload = {
      'integration': 'shopify',
      'store_url': storeUrl.trim(),
      if (accessToken != null && accessToken.isNotEmpty) 'access_token': accessToken.trim(),
      'order_automation_enabled': orderAutomationEnabled,
    };

    final res = await _repository.updateIntegration(payload);
    isSaving.value = false;

    if (res['success'] == true) {
      Get.snackbar('Success', 'Shopify integration updated', snackPosition: SnackPosition.BOTTOM);
      fetchIntegrations();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to update Shopify', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> disconnectShopify() async {
    isSaving.value = true;
    final payload = {
      'integration': 'shopify',
      'store_url': '',
      'access_token': '',
    };
    final res = await _repository.updateIntegration(payload);
    isSaving.value = false;

    if (res['success'] == true) {
      Get.snackbar('Disconnected', 'Shopify disconnected', snackPosition: SnackPosition.BOTTOM);
      fetchIntegrations();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to disconnect', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> saveWooCommerceConfig({
    required String storeUrl,
    String? consumerKey,
    String? consumerSecret,
    bool orderAutomationEnabled = true,
  }) async {
    isSaving.value = true;
    final payload = {
      'integration': 'woocommerce',
      'store_url': storeUrl.trim(),
      if (consumerKey != null && consumerKey.isNotEmpty) 'consumer_key': consumerKey.trim(),
      if (consumerSecret != null && consumerSecret.isNotEmpty) 'consumer_secret': consumerSecret.trim(),
      'order_automation_enabled': orderAutomationEnabled,
    };

    final res = await _repository.updateIntegration(payload);
    isSaving.value = false;

    if (res['success'] == true) {
      Get.snackbar('Success', 'WooCommerce integration updated', snackPosition: SnackPosition.BOTTOM);
      fetchIntegrations();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to update WooCommerce', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  final RxList<Map<String, dynamic>> templateObjects = <Map<String, dynamic>>[].obs;
  final RxList<String> availableTemplates = <String>[].obs;
  final RxBool isLoadingTemplates = false.obs;

  Future<void> fetchTemplates() async {
    isLoadingTemplates.value = true;
    try {
      final res = await _repository.getTemplates();
      if (res['success'] == true && res['data'] is List) {
        final rawList = (res['data'] as List)
            .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
            .toList();

        templateObjects.assignAll(rawList);
        final names = rawList
            .map((t) => t['name']?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .toSet()
            .toList();
        availableTemplates.assignAll(names);
      }
    } catch (_) {}
    isLoadingTemplates.value = false;
  }


  Future<bool> updateAutomationModule(String integration, String moduleId, Map<String, dynamic> moduleConfig) async {
    isSaving.value = true;
    final currentAutomation = integration == 'shopify'
        ? Map<String, dynamic>.from(shopify.value?.automation ?? {})
        : Map<String, dynamic>.from(woocommerce.value?.automation ?? {});

    currentAutomation[moduleId] = moduleConfig;

    final payload = {
      'integration': integration,
      'automation': currentAutomation,
    };

    final res = await _repository.updateIntegration(payload);
    isSaving.value = false;

    if (res['success'] == true) {
      Get.snackbar('Success', 'Automation module configuration saved', snackPosition: SnackPosition.BOTTOM);
      fetchIntegrations();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to update automation', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }


  Future<bool> disconnectWooCommerce() async {

    isSaving.value = true;
    final payload = {
      'integration': 'woocommerce',
      'store_url': '',
      'consumer_key': '',
      'consumer_secret': '',
    };
    final res = await _repository.updateIntegration(payload);
    isSaving.value = false;

    if (res['success'] == true) {
      Get.snackbar('Disconnected', 'WooCommerce disconnected', snackPosition: SnackPosition.BOTTOM);
      fetchIntegrations();
      return true;
    } else {
      Get.snackbar('Error', res['error'] ?? 'Failed to disconnect', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
