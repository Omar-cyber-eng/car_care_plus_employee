import 'package:car_care_plus/features/orders/data/order_model.dart';

// مشكلة مقترحة (/suggested-problems) — لاختيار problem_type_id في road-detail.
class SuggestedProblem {
  final int id;
  final String name;

  const SuggestedProblem({required this.id, required this.name});

  factory SuggestedProblem.fromJson(Map<String, dynamic> json) {
    final ar = json['name_ar']?.toString();
    final en = json['name']?.toString();
    final name = (ar != null && ar.isNotEmpty)
        ? ar
        : (en != null && en.isNotEmpty ? en : 'مشكلة #${json['id']}');
    return SuggestedProblem(id: json['id'] ?? 0, name: name);
  }
}

// عنصر في سجل حالة الطلب (bookings/{id}/status-history).
class StatusHistoryEntry {
  final OrderStatus status;
  final String note;
  final String changedAt;

  const StatusHistoryEntry({
    required this.status,
    required this.note,
    required this.changedAt,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return StatusHistoryEntry(
      status: orderStatusFromString(json['status']?.toString()),
      note: (json['note'] ?? json['comment'] ?? '').toString(),
      changedAt:
          (json['created_at'] ?? json['changed_at'] ?? '').toString(),
    );
  }
}
