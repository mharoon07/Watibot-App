import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/auth/models/login_model.dart';
import 'package:watibot/modules/auth/repositories/auth_repository.dart';
import 'package:watibot/modules/auth/routes/auth_routes.dart';

class LoginController extends GetxController {
  final AuthRepository _repository;

  LoginController(this._repository);

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final emailController = TextEditingController(text: 'admin@watibot.com');
  final passwordController = TextEditingController(text: 'Password@123');

  // Focus Nodes
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  // Observables
  final hidePassword = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }

  void togglePassword() {
    hidePassword.value = !hidePassword.value;
  }

  void goToRegister() {
    Get.toNamed(AuthRoutes.register);
  }

  void forgotPassword() {
    Get.toNamed(AuthRoutes.forgotPassword);
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final model = LoginModel(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final success = await _repository.login(model);

      if (success) {
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Error',
          'Invalid credentials. Please try again.',
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
