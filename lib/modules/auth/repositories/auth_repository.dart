import 'package:watibot/modules/auth/models/login_model.dart';
import 'package:watibot/modules/auth/models/register_model.dart';

class AuthRepository {
  Future<bool> register(RegisterModel model) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate dummy success
    return true;
  }

  Future<bool> login(LoginModel model) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate dummy success
    return true;
  }

  Future<bool> sendResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate dummy success
    return true;
  }

  Future<bool> verifyOTP(String email, String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate dummy success
    return otp.length == 6; // Simple validation for dummy
  }

  Future<bool> resendOTP(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate dummy success
    return true;
  }
}
