import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';

// طبقة بيانات الطلبات — تضرب /bookings (Scoping تلقائي من الباك حسب الدور).
class OrdersRepo {
  final ApiService _apiService;

  OrdersRepo(this._apiService);

  /// قائمة الطلبات. الاستجابة مُرقّمة: data.data (المصفوفة) + data.meta.
  /// نتعامل بمرونة إن عادت data مصفوفة مباشرة.
  Future<List<OrderModel>> getOrders() async {
    final response = await _apiService.get(endpoint: ApiConstants.bookings);
    final data = response.data['data'];
    final List list = data is List
        ? data
        : (data is Map ? (data['data'] as List? ?? const []) : const []);
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> getOrderDetails(int id) async {
    final response =
        await _apiService.get(endpoint: ApiConstants.bookingDetails(id));
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// بدء التنفيذ (بلا body) — يرجع الطلب بعد التحول إلى in_progress.
  Future<OrderModel> startOrder(int id) async {
    final response =
        await _apiService.post(endpoint: ApiConstants.startBooking(id));
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// إنهاء الطلب (بلا body) — يرجع الطلب بعد التحول إلى completed.
  Future<OrderModel> completeOrder(int id) async {
    final response =
        await _apiService.post(endpoint: ApiConstants.completeBooking(id));
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// تأكيد استلام النقد — يأخذ معرّف الدفعة (payment.id) وليس معرّف الطلب.
  Future<void> confirmCash(int paymentId) async {
    await _apiService.post(endpoint: ApiConstants.confirmCash(paymentId));
  }
}
