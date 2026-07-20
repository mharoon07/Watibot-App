import 'package:get/get.dart';
import 'package:watibot/modules/contacts/models/contact_model.dart';
import 'package:watibot/modules/contacts/repositories/contacts_repository.dart';

class ContactsController extends GetxController {
  final ContactsRepository _repository;

  ContactsController(this._repository);

  final contacts = <ContactModel>[].obs;
  final filteredContacts = <ContactModel>[].obs;
  
  final loading = true.obs;
  final selectedFilter = 0.obs;
  final searchQuery = ''.obs;

  final filterChips = [
    'All',
    'Recent',
    'Favorites',
    'Customers',
    'Leads',
    'VIP',
    'Blocked',
  ];

  @override
  void onInit() {
    super.onInit();
    loadContacts();

    debounce(searchQuery, (_) => filterContacts(), time: const Duration(milliseconds: 300));
  }

  Future<void> loadContacts() async {
    loading.value = true;
    try {
      final data = await _repository.getContacts();
      contacts.assignAll(data);
      filterContacts();
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshContacts() async {
    await loadContacts();
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
    filterContacts();
  }

  void searchContacts(String query) {
    searchQuery.value = query;
  }

  void filterContacts() {
    var result = contacts.toList();

    // 1. Search Filter
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) || 
               c.company.toLowerCase().contains(q) ||
               c.phone.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Chip Filter
    final filterName = filterChips[selectedFilter.value];
    switch (filterName) {
      case 'Recent':
        // Filter contacts interacted with in the last 7 days
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        result = result.where((c) => c.lastInteraction.isAfter(weekAgo)).toList();
        break;
      case 'Favorites':
        result = result.where((c) => c.isFavorite).toList();
        break;
      case 'Customers':
        result = result.where((c) => c.status == ContactStatus.customer).toList();
        break;
      case 'Leads':
        result = result.where((c) => c.status == ContactStatus.lead).toList();
        break;
      case 'VIP':
        result = result.where((c) => c.status == ContactStatus.vip).toList();
        break;
      case 'Blocked':
        result = result.where((c) => c.status == ContactStatus.blocked).toList();
        break;
      case 'All':
      default:
        // Exclude blocked from "All" unless explicitly selected
        result = result.where((c) => c.status != ContactStatus.blocked).toList();
        break;
    }

    // Sort alphabetically by default
    result.sort((a, b) => a.name.compareTo(b.name));

    filteredContacts.assignAll(result);
  }

  void toggleFavorite(String id) {
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = contacts[index];
      contacts[index] = ContactModel(
        id: old.id,
        name: old.name,
        phone: old.phone,
        email: old.email,
        company: old.company,
        avatarUrl: old.avatarUrl,
        lastSeen: old.lastSeen,
        status: old.status,
        isFavorite: !old.isFavorite,
        tags: old.tags,
        lastInteraction: old.lastInteraction,
        isWhatsappVerified: old.isWhatsappVerified,
        unreadCount: old.unreadCount,
      );
      filterContacts();
      Get.snackbar(
        old.isFavorite ? 'Removed from Favorites' : 'Added to Favorites',
        '${old.name} was updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteContact(String id) {
    final contact = contacts.firstWhereOrNull((c) => c.id == id);
    if (contact != null) {
      contacts.removeWhere((c) => c.id == id);
      filterContacts();
      Get.snackbar(
        'Contact Deleted',
        '${contact.name} has been removed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void blockContact(String id) {
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = contacts[index];
      contacts[index] = ContactModel(
        id: old.id,
        name: old.name,
        phone: old.phone,
        email: old.email,
        company: old.company,
        avatarUrl: old.avatarUrl,
        lastSeen: old.lastSeen,
        status: ContactStatus.blocked,
        isFavorite: false, // Remove from favorites if blocked
        tags: old.tags,
        lastInteraction: old.lastInteraction,
        isWhatsappVerified: old.isWhatsappVerified,
        unreadCount: 0,
      );
      filterContacts();
      Get.snackbar(
        'Contact Blocked',
        '${old.name} has been blocked and will no longer be able to message you.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void archiveContact(String id) {
    Get.snackbar(
      'Contact Archived',
      'Contact moved to archive.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openChat(ContactModel contact) {
    // Navigate to Chat View. We can simulate navigating to Inbox module here
    // For now we'll just show a snackbar
    Get.snackbar(
      'Opening Chat',
      'Starting conversation with ${contact.name}...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void callContact(ContactModel contact) {
    Get.snackbar(
      'Calling',
      'Dialing ${contact.phone}...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addContact() {
    Get.snackbar(
      'New Contact',
      'Opening contact creation form...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
