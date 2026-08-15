// سيارة العميل (CarResource) — عرض للقراءة فقط ضمن سياق الطلب.
class CustomerCar {
  final int id;
  final String model;
  final String plateNumber;
  final int? year;
  final String color;
  final String fuelType;
  final int? cylinders;
  final int? mileage;
  final String? imageUrl;
  final String carTypeName;
  final String branchName;

  const CustomerCar({
    required this.id,
    required this.model,
    required this.plateNumber,
    required this.year,
    required this.color,
    required this.fuelType,
    required this.cylinders,
    required this.mileage,
    required this.imageUrl,
    required this.carTypeName,
    required this.branchName,
  });

  factory CustomerCar.fromJson(Map<String, dynamic> json) {
    final carType = json['car_type'] as Map<String, dynamic>?;
    final branch = json['branch'] as Map<String, dynamic>?;
    return CustomerCar(
      id: json['id'] ?? 0,
      model: (json['model'] ?? 'مركبة').toString(),
      plateNumber: (json['plate_number'] ?? '').toString(),
      year: json['year'] is int ? json['year'] as int : null,
      color: (json['color'] ?? '').toString(),
      fuelType: (json['fuel_type'] ?? '').toString(),
      cylinders: json['cylinders'] is int ? json['cylinders'] as int : null,
      mileage: json['mileage'] is int ? json['mileage'] as int : null,
      imageUrl: (json['image_url'] as String?)?.isNotEmpty == true
          ? json['image_url'] as String
          : null,
      carTypeName: carType == null
          ? ''
          : (carType['name_ar'] ?? carType['name'] ?? '').toString(),
      branchName: branch == null
          ? ''
          : (branch['name_ar'] ?? branch['name'] ?? '').toString(),
    );
  }

  String get fuelLabel {
    switch (fuelType.toLowerCase()) {
      case 'petrol':
      case 'gasoline':
        return 'بنزين';
      case 'diesel':
        return 'ديزل';
      case 'hybrid':
        return 'هايبرايد';
      case 'electric':
        return 'كهرباء';
      default:
        return fuelType.isEmpty ? 'غير محدد' : fuelType;
    }
  }
}
