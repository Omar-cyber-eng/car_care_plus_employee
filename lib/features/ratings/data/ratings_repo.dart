import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/features/ratings/data/rating_model.dart';

// التقييمات — عرض فقط (الموظف/الورشة يرون تقييماتهم، الباك يصفّي تلقائياً).
class RatingsRepo {
  final ApiService _apiService;

  RatingsRepo(this._apiService);

  Future<List<RatingModel>> getRatings() async {
    final response = await _apiService.get(endpoint: ApiConstants.ratings);
    final data = response.data['data'];
    final List list = data is List
        ? data
        : (data is Map ? (data['data'] as List? ?? const []) : const []);
    return list
        .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
