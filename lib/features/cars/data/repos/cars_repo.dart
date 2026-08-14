import 'package:dio/dio.dart';
import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import '../models/car_model.dart';
import 'dart:io';

class CarsRepo {
  final ApiService _apiService;

  CarsRepo(this._apiService);

  /// جلب قائمة سيارات المستخدم
  Future<List<CarModel>> getUserCars() async {
    final response = await _apiService.get(
      endpoint: ApiConstants.userCars,
    );
    final List data = response.data['data'] as List;
    return data.map((e) => CarModel.fromJson(e)).toList();
  }

  /// إضافة سيارة جديدة مع صورة اختيارية
  Future<CarModel> addCar({
    required Map<String, dynamic> carData,
    String? imagePath,
  }) async {
    final Response response;

    if (imagePath != null && imagePath.isNotEmpty) {
      response = await _apiService.postWithFile(
        endpoint: ApiConstants.createCar,
        data: carData,
        filePath: imagePath,
        fileKey: 'image',
      );
    } else {
      response = await _apiService.post(
        endpoint: ApiConstants.createCar,
        data: carData,
      );
    }

    return CarModel.fromJson(response.data['data']);
  }

  /// جلب تفاصيل سيارة
  Future<CarModel> getCarDetails(int carId) async {
    final response = await _apiService.get(
      endpoint: '${ApiConstants.showCar}$carId',
    );
    return CarModel.fromJson(response.data['data']);
  }

  /// تعديل سيارة
  Future<CarModel> updateCar({
  required int carId,
  required Map<String, dynamic> carData,
  File? imageFile,
}) async {
  // 1. تحويل البيانات إلى Map قابلة للتعديل
  final formDataMap = Map<String, dynamic>.from(carData);

  // 2. إضافة محاكاة الـ PUT التي يتوقعها Laravel
  formDataMap['_method'] = 'PUT';

  // 3. إرفاق الصورة إن تم تحديدها من معرض الصور
  if (imageFile != null) {
    formDataMap['image'] = await MultipartFile.fromFile(
      imageFile.path,
      filename: imageFile.path.split('/').last,
    );
  }

  // 4. إرسال الطلب بنوع POST حصراً ليقرأ Laravel الـ FormData بشكل صحيح
  final response = await _apiService.post(
    endpoint: '${ApiConstants.updateCar}$carId',
    data: FormData.fromMap(formDataMap),
  );

  return CarModel.fromJson(response.data['data']);
}

  /// حذف سيارة
  Future<void> deleteCar(int carId) async {
    await _apiService.delete(
      endpoint: '${ApiConstants.deleteCar}$carId',
    );
  }
}