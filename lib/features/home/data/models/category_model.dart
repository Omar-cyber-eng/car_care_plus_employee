class CategoryModel {
  final int id;
  final String name;
  final String nameAr;
  final String? description;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}