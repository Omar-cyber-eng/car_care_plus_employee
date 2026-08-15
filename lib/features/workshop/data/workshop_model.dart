// ورشة (WorkshopResource) — دليل الورشة/الموظف §2.2.
class WorkshopModel {
  final int id;
  final String name;
  final String nameAr;
  final String address;
  final String city;
  final String latitude;
  final String longitude;
  final String status; // pending|approved|rejected|active|inactive|suspended
  final String ratingAvg;

  const WorkshopModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.ratingAvg,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) => WorkshopModel(
        id: json['id'] ?? 0,
        name: (json['name'] ?? '').toString(),
        nameAr: (json['name_ar'] ?? '').toString(),
        address: (json['address'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        latitude: (json['latitude'] ?? '').toString(),
        longitude: (json['longitude'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        ratingAvg: (json['rating_avg'] ?? '0').toString(),
      );

  String get statusLabel {
    switch (status) {
      case 'approved':
      case 'active':
        return 'معتمدة';
      case 'pending':
        return 'قيد المراجعة';
      case 'rejected':
        return 'مرفوضة';
      case 'inactive':
        return 'غير نشطة';
      case 'suspended':
        return 'موقوفة';
      default:
        return status;
    }
  }

  bool get isApproved => status == 'approved' || status == 'active';
}
