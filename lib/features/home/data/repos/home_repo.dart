import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';

class HomeRepo {
  final ApiService _apiService;

  HomeRepo(this._apiService);

  /// جلب قائمة التصنيفات
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiService.get(endpoint: ApiConstants.category);
    final List data = response.data['data'] as List;
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  /// جلب قائمة الخدمات (كل الخدمات أو خدمات قسم محدد)
  Future<List<ServiceModel>> getServices({int? categoryId}) async {
    // تحديد الـ Endpoint بناءً على اختيار القسم
    final String endpoint = categoryId != null
        ? ApiConstants.servicesByCategory(categoryId)
        : ApiConstants.service;

    final response = await _apiService.get(endpoint: endpoint);
    final List data = response.data['data'] as List;
    return data.map((e) => ServiceModel.fromJson(e)).toList();
  }
}