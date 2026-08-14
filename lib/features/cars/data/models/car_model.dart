class CarModel {
  final int id;
  final int userId;
  final int brandId;
  final int carTypeId;
  final int? branchId;
  final String plateNumber;
  final String model;
  final String year;
  final String color;
  final String fuelType;
  final int cylinders;
  final int mileage;
  final String? imageUrl;
  final bool isActive;
  final CarTypeModel? carType;
  final BranchModel? branch;

  CarModel({
    required this.id,
    required this.userId,
    required this.brandId,
    required this.carTypeId,
    this.branchId,
    required this.plateNumber,
    required this.model,
    required this.year,
    required this.color,
    required this.fuelType,
    required this.cylinders,
    required this.mileage,
    this.imageUrl,
    required this.isActive,
    this.carType,
    this.branch,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      brandId: json['brand_id'] as int? ?? 0,
      carTypeId: json['car_type_id'] as int? ?? 0,
      branchId: json['branch_id'] as int?,
      plateNumber: json['plate_number'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year']?.toString() ?? '',
      color: json['color'] as String? ?? '',
      fuelType: json['fuel_type'] as String? ?? '',
      cylinders: json['cylinders'] is int
          ? json['cylinders']
          : int.tryParse(json['cylinders']?.toString() ?? '') ?? 0,
      mileage: json['mileage'] is int
          ? json['mileage']
          : int.tryParse(json['mileage']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      carType: json['car_type'] != null
          ? CarTypeModel.fromJson(json['car_type'])
          : null,
      branch: json['branch'] != null
          ? BranchModel.fromJson(json['branch'])
          : null,
    );
  }

  /// Getter لمُعالجة وتنظيف رابط الصورة قبل العرض
  String? get cleanImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    String url = imageUrl!;

    // 1. استخراج الرابط الحقيقي المضمّن إذا كان مرجعاً بشكل مدمج مضاعف
    if (url.contains('http://') && url.lastIndexOf('http://') > 0) {
      url = url.substring(url.lastIndexOf('http://'));
    } else if (url.contains('https://') && url.lastIndexOf('https://') > 0) {
      url = url.substring(url.lastIndexOf('https://'));
    }

    // 2. إذا كان المسار نسبياً لا يبدأ بـ http/https
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('/')) {
        url = 'http://10.0.2.2:8000$url';
      } else {
        url = 'http://10.0.2.2:8000/storage/$url';
      }
    }

    // 3. تحويل localhost إلى IP المحاكي للأندرويد
    if (url.contains('localhost')) {
      url = url.replaceAll('localhost', '10.0.2.2');
    }

    return url;
  }
}

class CarTypeModel {
  final int id;
  final String name;
  final String nameAr;
  final double priceMultiplier;
  final bool isActive;

  CarTypeModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.priceMultiplier,
    required this.isActive,
  });

  factory CarTypeModel.fromJson(Map<String, dynamic> json) {
    return CarTypeModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      priceMultiplier:
          double.tryParse(json['price_multiplier']?.toString() ?? '') ?? 1.0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

class BranchModel {
  final int id;
  final String name;
  final String nameAr;
  final String? city;

  BranchModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.city,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      city: json['city'] as String?,
    );
  }
}