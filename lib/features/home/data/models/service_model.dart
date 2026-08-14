class ServiceModel {
  final int id;
  final int categoryId;
  final String name;
  final String nameAr;
  final String? description;
  final double basePrice;
  final bool isVipAvailable;
  final double vipExtraPrice;
  final int durationMinutes;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameAr,
    this.description,
    required this.basePrice,
    required this.isVipAvailable,
    required this.vipExtraPrice,
    required this.durationMinutes,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      description: json['description'] as String?,
      basePrice: double.tryParse(json['base_price'].toString()) ?? 0.0,
      isVipAvailable: json['is_vip_available'] == true || json['is_vip_available'] == 1,
      vipExtraPrice: double.tryParse(json['vip_extra_price'].toString()) ?? 0.0,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
    );
  }
}