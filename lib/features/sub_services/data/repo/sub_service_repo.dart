import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/features/service_details/data/models/subservice_model.dart';


class SubServiceRepo {
  final ApiService _apiService;

  SubServiceRepo(this._apiService);

  /// جلب الخدمات الفرعية المرتبطة بخدمة محددة
  Future<List<SubServiceModel>> getSubServicesByServiceId(int serviceId) async {
    final response = await _apiService.get(
      endpoint: 'services/$serviceId/sub-services',
    );

    final List data = response.data['data'] as List;
    return data.map((e) => SubServiceModel.fromJson(e)).toList();
  }
}