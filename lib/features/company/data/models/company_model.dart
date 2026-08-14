class CompanyModel {
  final int id;
  final String name;
  final String nameAr;
  final String commercialReg;
  final String taxNumber;
  final String address;
  final String status; // pending | approved | rejected
  final bool isActive;
  final String? createdAt;

  CompanyModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.commercialReg,
    required this.taxNumber,
    required this.address,
    required this.status,
    required this.isActive,
    this.createdAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      commercialReg: json['commercial_reg'] as String? ?? '',
      taxNumber: json['tax_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] as String?,
    );
  }
}
