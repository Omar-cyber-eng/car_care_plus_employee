class ServiceDetailsModel {
  final int id;
  final String name;
  final String nameAr;
  final String description;
  final double basePrice;
  final bool isVipAvailable;
  final double? vipExtraPrice;
  final int durationMinutes;
  final String imageUrl;

  ServiceDetailsModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.basePrice,
    required this.isVipAvailable,
    this.vipExtraPrice,
    required this.durationMinutes,
    required this.imageUrl,
  });

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    // دالة مساعدة لتحويل القيم العددية بأمان سواًء جاءت String أو num
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // رابط صورة افتراضية جودة عالية لخدمات السيارات عند عدم توفر حقل صورة من الـ API
const String defaultCarServiceAsset = 'assets/images/logo.png';


    return ServiceDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: parseDouble(json['base_price'] ?? json['price']),
      isVipAvailable: json['is_vip_available'] ?? false,
      vipExtraPrice: json['vip_extra_price'] != null
          ? parseDouble(json['vip_extra_price'])
          : null,
      durationMinutes: json['duration_minutes'] ?? json['duration'] ?? 0,
      imageUrl: (json['assets/images/logo.png'] ?? json['image'] ?? '').toString().isNotEmpty
          ? (json['assets/images/logo.png'] ?? json['image']).toString()
          : defaultCarServiceAsset,
    );
  }

  // Getters مساعدة لتسهيل القراءة في الـ UI
  String get displayTitle => nameAr.isNotEmpty ? nameAr : name;
  String get formattedDuration => '$durationMinutes دقيقة';
}