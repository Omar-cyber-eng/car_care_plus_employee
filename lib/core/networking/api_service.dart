import 'package:dio/dio.dart';
import 'dio_factory.dart';
import 'api_error_handler.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = DioFactory.getDio();
  }

  /// طلبات GET (جلب البيانات)
  Future<Response> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// طلبات POST (إنشاء بيانات)
  Future<Response> post({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// طلبات PUT (تعديل بيانات)
  Future<Response> put({
    required String endpoint,
    dynamic data,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
      );
      return response;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// طلبات DELETE (حذف)
  Future<Response> delete({
    required String endpoint,
    dynamic data,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
      );
      return response;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// طلبات رفع الصور والملفات (FormData)
  Future<Response> postWithFile({
    required String endpoint,
    required Map<String, dynamic> data,
    required String filePath,
    required String fileKey,
  }) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        ...data,
        fileKey: await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
      );
      return response;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}