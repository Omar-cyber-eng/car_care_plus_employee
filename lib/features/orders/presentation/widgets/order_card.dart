import 'package:flutter/material.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';

// بطاقة طلب واحد داخل قائمة الطلبات
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlueBlack.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    order.kind.icon,
                    color: AppColors.primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.serviceName,
                        style: TextStyles.Size15
                            .withColor(AppColors.darkBlueBlack)
                            .withWeight(FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${order.id} • ${order.customerName}',
                        style: TextStyles.Size10.withColor(AppColors.coolGrey),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.borderGrey),
            ),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.coolGrey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.scheduledAt,
                    style: TextStyles.Size10.withColor(AppColors.coolGrey),
                  ),
                ),
                Text(
                  '${order.price.toStringAsFixed(0)} ر.س',
                  style: TextStyles.Size15
                      .withColor(AppColors.primaryBlue)
                      .withWeight(FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.label,
        style: TextStyles.Size10
            .withColor(status.color)
            .withWeight(FontWeight.bold),
      ),
    );
  }
}
