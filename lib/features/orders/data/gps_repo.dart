import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';

// سجلّات GPS — إرسال فقط (POST). الموظف لا يقرأها (GET يرجع 403).
class GpsRepo {
  final ApiService _apiService;

  GpsRepo(this._apiService);

  Future<void> logPoint({
    required double latitude,
    required double longitude,
    int? orderId,
  }) async {
    await _apiService.post(
      endpoint: ApiConstants.gpsLogs,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (orderId != null) 'order_id': orderId,
      },
    );
  }
}
