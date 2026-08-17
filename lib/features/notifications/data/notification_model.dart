import 'package:flutter/material.dart';
import 'package:car_care_plus/core/resources/app_color.dart';

// إشعار داخل التطبيق (NotificationResource).
class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String type; // info | warning | success | error
  final String? referenceType; // order | ... (قد يكون null)
  final int? referenceId;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.referenceType,
    required this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      type: (json['type'] ?? 'info').toString(),
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id'] is int
          ? json['reference_id'] as int
          : int.tryParse(json['reference_id']?.toString() ?? ''),
      isRead: json['is_read'] == true,
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  IconData get icon {
    switch (type) {
      case 'success':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'error':
        return Icons.error_outline;
      case 'info':
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color get color {
    switch (type) {
      case 'success':
        return AppColors.successColor;
      case 'warning':
        return AppColors.warningColor;
      case 'error':
        return AppColors.errorColor;
      case 'info':
      default:
        return AppColors.primaryBlue;
    }
  }
}
