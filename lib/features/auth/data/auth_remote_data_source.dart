import 'package:car_care_plus/features/auth/data/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  // تسجيل الورشة فقط (الموظف ينشئه الأدمن ويسجل دخوله فقط)
  Future<UserModel> registerWorkshop({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String workshopName,
    required String workshopNameAr,
    required String workshopAddress,
    required String workshopCity,
    required String latitude,
    required String longitude,
  });

  Future<String> sendResetOtp({required String email});

  Future<String> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });

  Future<UserModel> getProfile();

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? imagePath,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 && response.data['status'] == 1) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'فشل تسجيل الدخول');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'تعذر الاتصال بالسيرفر');
    }
  }

  @override
  Future<UserModel> registerWorkshop({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String workshopName,
    required String workshopNameAr,
    required String workshopAddress,
    required String workshopCity,
    required String latitude,
    required String longitude,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'workshop_name': workshopName,
        'workshop_name_ar': workshopNameAr,
        'workshop_address': workshopAddress,
        'workshop_city': workshopCity,
        'latitude': latitude,
        'longitude': longitude,
      });

      final response = await dio.post(
        '$baseUrl/auth/register/workshop',
        data: formData,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['status'] == 1) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception(
          response.data['message'] ?? 'فشل تقديم طلب تسجيل الورشة',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'تعذر الاتصال بالسيرفر');
    }
  }

  @override
  Future<String> sendResetOtp({required String email}) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/password/otp/send',
        data: {'email': email},
      );
      if (response.statusCode == 200 && response.data['status'] == 1) {
        return response.data['message'] ??
            'تم إرسال رمز التحقق إلى بريدك الإلكتروني';
      } else {
        throw Exception(response.data['message'] ?? 'فشل إرسال رمز التحقق');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'تعذر الاتصال بالسيرفر');
    }
  }

  @override
  Future<String> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/password/otp/reset',
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      if (response.statusCode == 200 && response.data['status'] == 1) {
        return response.data['message'] ?? 'تم إعادة تعيين كلمة المرور بنجاح';
      } else {
        throw Exception(
          response.data['message'] ?? 'فشل إعادة تعيين كلمة المرور',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'تعذر الاتصال بالسيرفر');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get('$baseUrl/profile/showProfile');
      if (response.statusCode == 200 && response.data['status'] == 1) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'فشل جلب بيانات البروفايل');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'تعذر الاتصال بالسيرفر');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? imagePath,
  }) async {
    try {
      Map<String, dynamic> dataMap = {};
      if (name != null && name.isNotEmpty) dataMap['name'] = name;
      if (email != null && email.isNotEmpty) dataMap['email'] = email;
      if (phone != null && phone.isNotEmpty) dataMap['phone'] = phone;
      if (imagePath != null && imagePath.isNotEmpty) {
        dataMap['image_url'] = await MultipartFile.fromFile(imagePath);
      }

      final formData = FormData.fromMap(dataMap);
      final response = await dio.post(
        '$baseUrl/profile/updateProfile',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'فشل تحديث البيانات');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'تعذر الاتصال بالسيرفر');
    }
  }
}
