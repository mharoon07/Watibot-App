import 'package:get/get.dart';
import 'package:watibot/core/services/api_service.dart';
import 'package:watibot/core/services/storage_service.dart';
import 'package:watibot/modules/auth/models/login_model.dart';
import 'package:watibot/modules/auth/models/register_model.dart';

class AuthRepository {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  Future<Map<String, dynamic>> register(RegisterModel model) async {
    try {
      final response = await _api.post('/auth/register', data: {
        'name': model.fullName,
        'email': model.email,
        'password': model.password,
        'organizationName': model.companyName ?? '',
        'verificationMethod': model.verificationMethod,
        'phoneNumber': model.phoneNumber ?? '',
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        final token = response.data['projectApiKey'];
        final user = response.data['user'];

        if (token != null) {
          await _storage.saveToken(token);
        }
        
        if (user != null) {
          await _storage.saveUserData(
            id: user['id'],
            email: user['email'],
            name: user['name'],
            role: user['role'],
          );
        }
        return {
          'success': true,
          'requiresVerification': response.data['requiresVerification'] ?? true,
        };
      }
      return {'success': false};
    } catch (e) {
      // Let the controller handle the exception
      rethrow;
    }
  }

  Future<bool> login(LoginModel model) async {
    try {
      final response = await _api.post('/auth/login', data: model.toJson());

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['projectApiKey'];
        final user = response.data['user'];

        if (token != null) {
          await _storage.saveToken(token);
        }
        
        if (user != null) {
          await _storage.saveUserData(
            id: user['id'],
            email: user['email'],
            name: user['name'],
            role: user['role'],
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      // Let the controller handle the exception
      rethrow;
    }
  }

  Future<bool> sendResetEmail(String email) async {
    // Implement actual password reset API later
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool> verifyOTP(String email, String otp) async {
    // Implement actual OTP verify API later
    await Future.delayed(const Duration(seconds: 2));
    return otp.length == 6; 
  }

  Future<bool> resendOTP(String email) async {
    // Implement actual OTP resend API later
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
