import 'package:flutter/material.dart';
import 'package:car_care_plus/core/resources/app_color.dart';

// دورة حياة الطلب: pending → assigned → in_progress → completed (+ cancelled)
enum OrderStatus { pending, assigned, inProgress, completed, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'بانتظار الإسناد';
      case OrderStatus.assigned:
        return 'مُسند';
      case OrderStatus.inProgress:
        return 'قيد التنفيذ';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.coolGrey;
      case OrderStatus.assigned:
        return AppColors.primaryBlue;
      case OrderStatus.inProgress:
        return AppColors.warningColor;
      case OrderStatus.completed:
        return AppColors.successColor;
      case OrderStatus.cancelled:
        return AppColors.errorColor;
    }
  }
}

// نوع الخدمة — يُشتقّ من category.name (لا يوجد حقل service_kind في الباك).
enum OrderServiceKind { wash, maintenance, road, towing }

extension OrderServiceKindX on OrderServiceKind {
  String get label {
    switch (this) {
      case OrderServiceKind.wash:
        return 'غسيل';
      case OrderServiceKind.maintenance:
        return 'صيانة';
      case OrderServiceKind.road:
        return 'مساعدة على الطريق';
      case OrderServiceKind.towing:
        return 'سحب';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderServiceKind.wash:
        return Icons.local_car_wash_rounded;
      case OrderServiceKind.maintenance:
        return Icons.build_rounded;
      case OrderServiceKind.road:
        return Icons.car_crash_rounded;
      case OrderServiceKind.towing:
        return Icons.local_shipping_rounded;
    }
  }

  // هل يملك هذا النوع تفاصيل ميدانية يعبّئها الميكانيكي؟ (غير الغسيل)
  bool get hasFieldDetails => this != OrderServiceKind.wash;
}

// دفعة واحدة من مصفوفة payments في OrderResource.
class PaymentModel {
  final int id;
  final String method; // cash | card | wallet | point | package
  final String status; // pending | paid | failed | refunded
  final double amount;

  const PaymentModel({
    required this.id,
    required this.method,
    required this.status,
    required this.amount,
  });

  bool get isCashPending => method == 'cash' && status == 'pending';

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] ?? 0,
        method: (json['method'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        amount: _toDouble(json['amount']),
      );
}

// موديل الطلب = OrderResource (القسم 11.1 من دليل الورشة/الموظف).
class OrderModel {
  final int id;
  final OrderServiceKind kind;
  final String serviceName;
  final String customerName;
  final String customerPhone;
  final String carName;
  final String plateNumber;
  final String address;
  final String scheduledAt;
  final double price;
  final double cashDueAmount;
  final List<PaymentModel> payments;
  final OrderStatus status;

  const OrderModel({
    required this.id,
    required this.kind,
    required this.serviceName,
    required this.customerName,
    required this.customerPhone,
    required this.carName,
    required this.plateNumber,
    required this.address,
    required this.scheduledAt,
    required this.price,
    required this.cashDueAmount,
    required this.payments,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    final car = json['car'] as Map<String, dynamic>?;
    final paymentsJson = (json['payments'] as List?) ?? const [];

    return OrderModel(
      id: json['id'] ?? 0,
      kind: _kindFromCategory(category?['name']?.toString()),
      serviceName: (service?['name_ar'] ??
              service?['name'] ??
              category?['name_ar'] ??
              'خدمة')
          .toString(),
      customerName: (customer?['name'] ?? 'عميل').toString(),
      customerPhone: (customer?['phone'] ?? '').toString(),
      carName: (car?['model'] ?? car?['name'] ?? 'مركبة').toString(),
      plateNumber: (car?['plate_number'] ?? '').toString(),
      address: (json['location_address'] ?? '').toString(),
      scheduledAt: _formatDate(json['scheduled_at']?.toString()),
      price: _toDouble(json['total_price']),
      cashDueAmount: _toDouble(json['cash_due_amount']),
      payments: paymentsJson
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: _statusFromString(json['status']?.toString()),
    );
  }

  // أول دفعة نقدية معلّقة (لزر تأكيد النقد — يأخذ payment.id لا order.id).
  PaymentModel? get cashPendingPayment {
    for (final p in payments) {
      if (p.isCashPending) return p;
    }
    return null;
  }

  // يظهر زر تأكيد النقد متى وُجدت دفعة نقدية معلّقة (مستقلّ عن حالة الطلب).
  bool get needsCashConfirmation =>
      cashPendingPayment != null && status != OrderStatus.cancelled;

  String get paymentLabel {
    if (payments.isEmpty) return 'غير محدد';
    switch (payments.first.method) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة';
      case 'wallet':
        return 'محفظة';
      case 'point':
        return 'نقاط';
      case 'package':
        return 'باقة';
      default:
        return payments.first.method;
    }
  }

  bool get canStart => status == OrderStatus.assigned;
  bool get canComplete => status == OrderStatus.inProgress;
}

// يميّز النوع من category.name (الإنجليزي الثابت — لا تعتمد على category_id).
// ملاحظة: السحب (towing) حالة داخل Roadside تُعرف بوجود towing-detail — يُكشف في شاشة التفاصيل.
OrderServiceKind _kindFromCategory(String? name) {
  switch (name) {
    case 'Maintenance':
      return OrderServiceKind.maintenance;
    case 'Roadside Assistance':
      return OrderServiceKind.road;
    case 'Car Wash':
    default:
      return OrderServiceKind.wash;
  }
}

OrderStatus _statusFromString(String? s) {
  switch (s) {
    case 'assigned':
      return OrderStatus.assigned;
    case 'in_progress':
      return OrderStatus.inProgress;
    case 'completed':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'pending':
    default:
      return OrderStatus.pending;
  }
}

// decimal يأتي كنصوص من الباك — حوّله لأرقام بأمان.
double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

// scheduled_at بصيغة ISO — نعرضه بشكل مقروء (محلّي).
String _formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)} - '
      '${two(local.hour)}:${two(local.minute)}';
}
