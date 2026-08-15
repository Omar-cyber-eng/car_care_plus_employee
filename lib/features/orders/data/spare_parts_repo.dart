import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/features/orders/data/spare_part_models.dart';

// قطع الغيار — الميكانيكي فقط: إنشاء طلب + عرض طلباته. (الاعتماد على لوحة العميل.)
class SparePartsRepo {
  final ApiService _apiService;

  SparePartsRepo(this._apiService);

  List _listFrom(dynamic data) {
    if (data is List) return data;
    if (data is Map) return data['data'] as List? ?? const [];
    return const [];
  }

  /// كتالوج المواد لاختيار material_id.
  Future<List<MaterialItem>> getMaterials() async {
    final response = await _apiService.get(endpoint: ApiConstants.materials);
    return _listFrom(response.data['data'])
        .map((e) => MaterialItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// طلبات قطع الغيار للميكانيكي (نُصفّيها لطلب واحد اختيارياً).
  Future<List<SparePartRequest>> getRequests({int? orderId}) async {
    final response =
        await _apiService.get(endpoint: ApiConstants.sparePartRequests);
    final all = _listFrom(response.data['data'])
        .map((e) => SparePartRequest.fromJson(e as Map<String, dynamic>))
        .toList();
    return orderId == null
        ? all
        : all.where((r) => r.orderId == orderId).toList();
  }

  /// إنشاء طلب قطعة — الطلب يجب أن يكون مفتوحاً (غير مكتمل/ملغى).
  Future<void> createRequest({
    required int orderId,
    required int materialId,
    required int quantity,
    String? specifications,
    String? notes,
  }) async {
    await _apiService.post(
      endpoint: ApiConstants.sparePartRequests,
      data: {
        'order_id': orderId,
        'material_id': materialId,
        'quantity': quantity,
        if (specifications != null && specifications.isNotEmpty)
          'specifications': specifications,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }
}
