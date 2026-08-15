import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/features/orders/data/employee_report_model.dart';

// تقارير الموظف — إنشاء (غسّال+ميكانيكي) + عرض (يشمل الورشة).
class EmployeeReportsRepo {
  final ApiService _apiService;

  EmployeeReportsRepo(this._apiService);

  List _listFrom(dynamic data) {
    if (data is List) return data;
    if (data is Map) return data['data'] as List? ?? const [];
    return const [];
  }

  Future<List<EmployeeReport>> getReports({int? orderId}) async {
    final response = await _apiService.get(
      endpoint: ApiConstants.employeeReports,
      queryParameters: orderId == null ? null : {'order_id': orderId},
    );
    return _listFrom(response.data['data'])
        .map((e) => EmployeeReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createReport({
    required int orderId,
    required String problemDescription,
    List<String>? affectedParts,
    String? recommendation,
  }) async {
    await _apiService.post(
      endpoint: ApiConstants.employeeReports,
      data: {
        'order_id': orderId,
        'problem_description': problemDescription,
        if (affectedParts != null && affectedParts.isNotEmpty)
          'affected_parts': affectedParts,
        if (recommendation != null && recommendation.isNotEmpty)
          'recommendation': recommendation,
      },
    );
  }
}
