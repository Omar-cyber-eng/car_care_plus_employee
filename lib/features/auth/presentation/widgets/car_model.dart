class CarModel {
  final String brand;
  final String model;
  final int year;
  final String plateNumber;
  final String colorName;

  const CarModel({
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.colorName,
  });

  // سيارة المستخدم الوهمية للمرحلة الأولى
  static const CarModel myCar = CarModel(
    brand: 'تويوتا',
    model: 'كامري',
    year: 2022,
    plateNumber: 'أ ب ج 4521',
    colorName: 'أبيض لؤلؤي',
  );
}
