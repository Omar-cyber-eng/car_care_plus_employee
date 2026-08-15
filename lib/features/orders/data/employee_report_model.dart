// تقرير موظف عن طلب (employee-reports).
class EmployeeReport {
  final int id;
  final int orderId;
  final String problemDescription;
  final List<String> affectedParts;
  final String recommendation;
  final String status;
  final String employeeName;
  final String createdAt;

  const EmployeeReport({
    required this.id,
    required this.orderId,
    required this.problemDescription,
    required this.affectedParts,
    required this.recommendation,
    required this.status,
    required this.employeeName,
    required this.createdAt,
  });

  factory EmployeeReport.fromJson(Map<String, dynamic> json) {
    final parts = (json['affected_parts'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final employee = json['employee'] as Map<String, dynamic>?;
    final user = employee?['user'] as Map<String, dynamic>?;
    return EmployeeReport(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      problemDescription: (json['problem_description'] ?? '').toString(),
      affectedParts: parts,
      recommendation: (json['recommendation'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      employeeName: (user?['name'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}
