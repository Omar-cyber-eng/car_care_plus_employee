import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';
import 'package:car_care_plus/features/workshop/data/workshop_model.dart';

// ملف الورشة — GET ورشتي + تعديلها (المالك فقط).
class WorkshopRepo {
  final ApiService _apiService;

  WorkshopRepo(this._apiService);

  Future<WorkshopModel> getMyWorkshop() async {
    final response = await _apiService.get(endpoint: ApiConstants.myWorkshop);
    return WorkshopModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// تعديل الورشة — لا نرسل status/is_active (سوبر أدمن فقط يغيّرهما).
  Future<WorkshopModel> updateWorkshop({
    required int id,
    required String name,
    required String nameAr,
    required String address,
    required String city,
    required String latitude,
    required String longitude,
  }) async {
    // مسار workshops CRUD يستخدم أسماء حقول المورد (مؤكَّد من الباك): name/name_ar/
    // address/city/latitude/longitude — بلا بادئة workshop_ (تلك خاصة بالتسجيل).
    // لا نرسل status/rating_avg (يتجاهلهما الباك — يديرهما الأدمن/النظام).
    final response = await _apiService.post(
      endpoint: ApiConstants.workshop(id),
      data: {
        'name': name,
        'name_ar': nameAr,
        'address': address,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return WorkshopModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// سجل صيانة/مساعدة سيارة زارت ورشتي — يرجع قائمة OrderResource.
  Future<List<OrderModel>> getCarHistory(int carId) async {
    final response = await _apiService.get(
      endpoint: ApiConstants.workshopCarHistory(carId),
    );
    final data = response.data['data'];
    final List list = data is List
        ? data
        : (data is Map ? (data['data'] as List? ?? const []) : const []);
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
