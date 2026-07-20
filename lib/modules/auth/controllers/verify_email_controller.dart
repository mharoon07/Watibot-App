import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watibot/modules/auth/repositories/auth_repository.dart';

class VerifyEmailController extends GetxController {
  final AuthRepository _repository;

  VerifyEmailController(this._repository);

  String email = '';
  final otp = ''.obs;
  
  final countdown = 59.obs;
  final canResend = false.obs;
  final isLoading = false.obs;
  
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['email'] != null) {
      email = Get.arguments['email'];
    }
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    countdown.value = 59;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void setOtp(String val) {
    otp.value = val;
  }

  void changeEmail() {
    Get.back();
  }

  Future<void> resendCode() async {
    if (!canResend.value) return;

    isLoading.value = true;
    try {
      final success = await _repository.resendOTP(email);
      if (success) {
        Get.snackbar(
          'Success',
          'Verification code has been resent.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        startTimer();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend code.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyCode() async {
    if (otp.value.length != 6) {
      Get.snackbar(
        'Invalid',
        'Please enter a valid 6-digit code.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    isLoading.value = true;

    try {
      final success = await _repository.verifyOTP(email, otp.value);

      if (success) {
        Get.snackbar(
          'Verified',
          'Your email has been verified successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        // TODO: Navigate to reset password or next step
        // Get.offAllNamed(AuthRoutes.resetPassword); 
      } else {
        Get.snackbar(
          'Error',
          'Invalid verification code.',
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
