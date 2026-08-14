import 'package:flutter/material.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';

// شارة حالة الشركة: قيد المراجعة / معتمد / مرفوض
class CompanyStatusBadge extends StatelessWidget {
  final String status;

  const CompanyStatusBadge({super.key, required this.status});

  ({String label, Color color, IconData icon}) get _style {
    switch (status) {
      case 'approved':
        return (
          label: 'معتمد',
          color: AppColors.successColor,
          icon: Icons.verified_rounded,
        );
      case 'rejected':
        return (
          label: 'مرفوض',
          color: AppColors.errorColor,
          icon: Icons.cancel_rounded,
        );
      case 'pending':
      default:
        return (
          label: 'قيد المراجعة',
          color: AppColors.warningColor,
          icon: Icons.hourglass_top_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: s.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, color: s.color, size: 16),
          const SizedBox(width: 6),
          Text(
            s.label,
            style: TextStyles.Size10.withColor(s.color).withWeight(FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
