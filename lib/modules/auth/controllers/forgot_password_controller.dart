import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/auth/repositories/auth_repository.dart';
import 'package:watibot/modules/auth/routes/auth_routes.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _repository;

  ForgotPasswordController(this._repository);

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final emailFocus = FocusNode();

  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    emailFocus.dispose();
    super.onClose();
  }

  void goToLogin() {
    Get.back(); // Or Get.offAllNamed(AuthRoutes.login) if prefer absolute back
  }

  Future<void> sendVerificationCode() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final success = await _repository.sendResetEmail(emailController.text.trim());

      if (success) {
        Get.snackbar(
          'Email Sent',
          'Verification code has been sent to your email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        Get.toNamed(
          AuthRoutes.verifyEmail,
          arguments: {'email': emailController.text.trim()},
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to send verification code. Please try again.',
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
