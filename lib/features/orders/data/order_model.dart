import 'package:flutter/material.dart';
import 'package:car_care_plus/core/resources/app_color.dart';

enum OrderStatus { completed, inProgress, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.inProgress:
        return 'قيد التنفيذ';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.completed:
        return AppColors.successColor;
      case OrderStatus.inProgress:
        return AppColors.warningColor;
      case OrderStatus.cancelled:
        return AppColors.errorColor;
    }
  }
}

class OrderModel {
  final String id;
  final String serviceName;
  final IconData icon;
  final String date;
  final double price;
  final OrderStatus status;

  const OrderModel({
    required this.id,
    required this.serviceName,
    required this.icon,
    required this.date,
    required this.price,
    required this.status,
  });

  // سجل طلبات وهمي للمرحلة الأولى
  static const List<OrderModel> sampleOrders = [
    OrderModel(
      id: '#1043',
      serviceName: 'خدمة غسيل خارجي',
      icon: Icons.local_car_wash_rounded,
      date: '28 يوليو 2026 - 3:30 م',
      price: 15000,
      status: OrderStatus.inProgress,
    ),
    OrderModel(
      id: '#1039',
      serviceName: 'غسيل مجدول أسبوعي',
      icon: Icons.event_available_rounded,
      date: '21 يوليو 2026 - 10:00 ص',
      price: 12000,
      status: OrderStatus.completed,
    ),
    OrderModel(
      id: '#1028',
      serviceName: 'مساعدة طارئة - تبديل إطار',
      icon: Icons.warning_amber_rounded,
      date: '14 يوليو 2026 - 8:15 م',
      price: 25000,
      status: OrderStatus.completed,
    ),
    OrderModel(
      id: '#1015',
      serviceName: 'غسيل داخلي وتلميع',
      icon: Icons.local_car_wash_rounded,
      date: '2 يوليو 2026 - 1:00 م',
      price: 20000,
      status: OrderStatus.cancelled,
    ),
  ];
}
