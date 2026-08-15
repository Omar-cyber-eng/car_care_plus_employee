// تقييم (RatingResource) — عرض للقراءة فقط في تطبيق الموظف/الورشة.
class RatingModel {
  final int id;
  final int orderId;
  final String customerName;
  final int serviceRating;
  final int? employeeRating;
  final int? workshopRating;
  final String comment;
  final String createdAt;

  const RatingModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.serviceRating,
    required this.employeeRating,
    required this.workshopRating,
    required this.comment,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    int? asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '');
    return RatingModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      customerName: (customer?['name'] ?? 'عميل').toString(),
      serviceRating: asInt(json['service_rating']) ?? 0,
      employeeRating: asInt(json['employee_rating']),
      workshopRating: asInt(json['workshop_rating']),
      comment: (json['comment'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}
