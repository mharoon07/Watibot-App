import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
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
  final phoneController = TextEditingController();

  // Focus Nodes
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final companyFocus = FocusNode();
  final passwordFocus = FocusNode();
  final phoneFocus = FocusNode();

  // Observables
  final agreeTerms = false.obs;
  final hidePassword = true.obs;
  final isLoading = false.obs;
  
  // 'email' or 'phone'
  final verificationMethod = 'email'.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    companyController.dispose();
    passwordController.dispose();
    phoneController.dispose();

    nameFocus.dispose();
    emailFocus.dispose();
    companyFocus.dispose();
    passwordFocus.dispose();
    phoneFocus.dispose();
    
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

  void setVerificationMethod(String method) {
    verificationMethod.value = method;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (verificationMethod.value == 'phone' && phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Phone number is required for WhatsApp verification.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
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
        verificationMethod: verificationMethod.value,
        phoneNumber: phoneController.text.trim(),
      );

      final result = await _repository.register(model);

      if (result['success'] == true) {
        if (result['requiresVerification'] == true) {
          Get.snackbar(
            'Check your inbox',
            'Please enter the verification code sent to you.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue.shade100,
            colorText: Colors.blue.shade900,
          );
          // Navigate to OTP screen
          Get.toNamed('/verify-email', arguments: {
            'email': model.email,
            'method': model.verificationMethod,
            'phone': model.phoneNumber,
          });
        } else {
          Get.snackbar(
            'Success',
            'Account created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
          );
          Get.offAllNamed('/home');
        }
      } else {
        Get.snackbar(
          'Error',
          'Registration failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
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
