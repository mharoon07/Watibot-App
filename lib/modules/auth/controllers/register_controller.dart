import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/auth/models/register_model.dart';
import 'package:watibot/modules/auth/repositories/auth_repository.dart';

class RegisterController extends GetxController {
  final AuthRepository _repository;

  RegisterController(this._repository);

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final passwordController = TextEditingController();

  // Focus Nodes
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final companyFocus = FocusNode();
  final passwordFocus = FocusNode();

  // Observables
  final agreeTerms = false.obs;
  final hidePassword = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    companyController.dispose();
    passwordController.dispose();

    nameFocus.dispose();
    emailFocus.dispose();
    companyFocus.dispose();
    passwordFocus.dispose();
    
    super.onClose();
  }

  void togglePassword() {
    hidePassword.value = !hidePassword.value;
  }

  void toggleTerms(bool? value) {
    if (value != null) {
      agreeTerms.value = value;
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!agreeTerms.value) {
      Get.snackbar(
        'Error',
        'You must agree to the Terms of Service and Privacy Policy.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isLoading.value = true;

    try {
      final model = RegisterModel(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        companyName: companyController.text.trim(),
        password: passwordController.text,
      );

      final success = await _repository.register(model);

      if (success) {
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        Get.snackbar(
          'Error',
          'Registration failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
