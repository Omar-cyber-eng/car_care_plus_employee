import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'انتهت مهلة الاتصال بالسيرفر';
        case DioExceptionType.sendTimeout:
          return 'استغرق إرسال البيانات وقتاً طويلاً';
        case DioExceptionType.receiveTimeout:
          return 'استغرق استلام البيانات وقتاً طويلاً';
        case DioExceptionType.badResponse:
          return _handleBadResponse(error.response);
        case DioExceptionType.cancel:
          return 'تم إلغاء الطلب';
        case DioExceptionType.connectionError:
          return 'تعذر الاتصال بالسيرفر، تأكد من تشغيل XAMPP ومن الاتصال';
        default:
          return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً';
      }
    } else {
      return error.toString();
    }
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) return 'حدث خطأ في الخادم';

    // استخراج رسالة الخطأ من لارافل إن وجدت
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      return data['message'];
    }

    switch (response.statusCode) {
      case 400:
        return 'طلب غير صحيح';
      case 401:
        return 'جلسة العمل انتهت، يرجى إعادة تسجيل الدخول';
      case 403:
        return 'ليس لديك صلاحية للوصول لهذا العنصر';
      case 404:
        return 'العنصر المطلوبة غير موجود';
      case 422:
        return 'البيانات المدخلة غير صحيحة';
      case 500:
        return 'خطأ داخلي في الخادم';
      default:
        return 'حدث خطأ في الاتصال (${response.statusCode})';
    }
  }
}