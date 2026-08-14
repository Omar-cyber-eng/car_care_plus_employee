import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import '../models/company_model.dart';

class CompanyRepo {
  final ApiService _apiService;

  CompanyRepo(this._apiService);

  /// جلب شركة المستخدم الحالي
  Future<CompanyModel> getMyCompany() async {
    final response = await _apiService.get(
      endpoint: ApiConstants.myCompany,
    );
    return CompanyModel.fromJson(response.data['data']);
  }

  /// تعديل بيانات الشركة (POST لا PUT). لا تُرسل status ولا is_active
  Future<CompanyModel> updateCompany({
    required int companyId,
    required Map<String, dynamic> companyData,
  }) async {
    final response = await _apiService.post(
      endpoint: '${ApiConstants.company}$companyId',
      data: companyData,
    );
    return CompanyModel.fromJson(response.data['data']);
  }
}
