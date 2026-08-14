import 'package:car_care_plus/core/networking/api_service.dart';
import '../models/service_details_model.dart';

class ServiceDetailsRepo {
  final ApiService _apiService;

  ServiceDetailsRepo(this._apiService);

  Future<ServiceDetailsModel> getServiceDetails(int serviceId) async {
    final response = await _apiService.get(
      endpoint: '/services/$serviceId',
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return ServiceDetailsModel.fromJson(responseData['data']);
    }

    return ServiceDetailsModel.fromJson(responseData);
  }
}