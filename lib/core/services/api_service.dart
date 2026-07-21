import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:watibot/core/services/storage_service.dart';

class ApiService extends GetxService {
  late Dio _dio;

  // Using ngrok URL to bypass local network/firewall restrictions
  static const String baseUrl = 'https://scorch-gorged-dad.ngrok-free.dev/api/v1';

  static Map<String, String>? getMediaHeaders(String url) {
    if (url.contains('cloudinary.com')) {
      return null;
    }
    final storage = Get.find<StorageService>();
    if (storage.hasToken) {
      return {
        'Authorization': 'Bearer ${storage.getToken()}',
        'ngrok-skip-browser-warning': 'true',
      };
    }
    return null;
  }

  Future<ApiService> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Get.find<StorageService>().getToken();
        if (token != null) {
          // Using projectApiKey as Bearer token or custom header depending on your backend.
          // Adjust this header based on what the Next.js backend expects for API requests.
          options.headers['Authorization'] = 'Bearer $token'; 
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          Get.find<StorageService>().clearAll();
          Get.offAllNamed('/login'); // We use string literal to avoid circular dependency
        }
        return handler.next(e);
      },
    ));

    return this;
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      // Re-throw or handle specific errors here
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['error'] ?? e.message ?? 'Unknown error occurred',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ApiException(message: 'Network error: ${e.message}');
      }
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['error'] ?? e.message ?? 'Unknown error occurred',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ApiException(message: 'Network error: ${e.message}');
      }
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
