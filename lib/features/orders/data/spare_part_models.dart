// عنصر من كتالوج المواد (/materials) — نختار منه material_id لطلب قطعة الغيار.
class MaterialItem {
  final int id;
  final String name;

  const MaterialItem({required this.id, required this.name});

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    final ar = json['name_ar']?.toString();
    final en = json['name']?.toString();
    final name = (ar != null && ar.isNotEmpty)
        ? ar
        : (en != null && en.isNotEmpty ? en : 'مادة #${json['id']}');
    return MaterialItem(id: json['id'] ?? 0, name: name);
  }
}

// طلب قطعة غيار (SparePartRequestResource).
class SparePartRequest {
  final int id;
  final int orderId;
  final String materialName;
  final int quantity;
  final String specifications;
  final String status; // pending|approved|rejected|ordered|received
  final String notes;

  const SparePartRequest({
    required this.id,
    required this.orderId,
    required this.materialName,
    required this.quantity,
    required this.specifications,
    required this.status,
    required this.notes,
  });

  factory SparePartRequest.fromJson(Map<String, dynamic> json) {
    final material = json['material'] as Map<String, dynamic>?;
    final materialName = material == null
        ? 'قطعة #${json['material_id'] ?? ''}'
        : (material['name_ar'] ?? material['name'] ?? 'قطعة').toString();
    return SparePartRequest(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      materialName: materialName,
      quantity: json['quantity'] ?? 0,
      specifications: (json['specifications'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'مُعتمد';
      case 'rejected':
        return 'مرفوض';
      case 'ordered':
        return 'قيد الطلب';
      case 'received':
        return 'مُستلَم';
      case 'pending':
      default:
        return 'بانتظار موافقة العميل';
    }
  }
}
