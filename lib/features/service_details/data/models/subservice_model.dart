class SubServiceModel {
  final int id;
  final int serviceId;
  final String name;
  final String nameAr;
  final String description;
  final double price;
  final bool isActive;

  SubServiceModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.price,
    required this.isActive,
  });

  factory SubServiceModel.fromJson(Map<String, dynamic> json) {
    return SubServiceModel(
      id: json['id'],
      serviceId: json['service_id'],
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}