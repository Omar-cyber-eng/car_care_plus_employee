import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';
import 'package:car_care_plus/features/orders/logic/orders_cubit.dart';
import 'package:car_care_plus/features/orders/logic/orders_state.dart';
import 'package:car_care_plus/features/orders/presentation/order_service_detail_page.dart';

class OrderDetailsPage extends StatelessWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.surfaceWhite,
        elevation: 0,
        title: Text(
          'تفاصيل الطلب #$orderId',
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, _) {
          final order = context.read<OrdersCubit>().orderById(orderId);
          if (order == null) {
            return Center(
              child: Text(
                'الطلب غير موجود',
                style: TextStyles.Size15.withColor(AppColors.coolGrey),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderCard(order: order),
                const SizedBox(height: 16),
                _StatusTimeline(status: order.status),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'العميل',
                  rows: [
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: 'الاسم',
                      value: order.customerName,
                    ),
                    _DetailRow(
                      icon: Icons.phone_android_rounded,
                      label: 'الهاتف',
                      value: order.customerPhone,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'السيارة',
                  rows: [
                    _DetailRow(
                      icon: Icons.directions_car_outlined,
                      label: 'المركبة',
                      value: order.carName,
                    ),
                    _DetailRow(
                      icon: Icons.confirmation_number_outlined,
                      label: 'رقم اللوحة',
                      value: order.plateNumber,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'تفاصيل الخدمة',
                  rows: [
                    _DetailRow(
                      icon: order.kind.icon,
                      label: 'النوع',
                      value: '${order.kind.label} — ${order.serviceName}',
                    ),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'الموقع',
                      value: order.address,
                    ),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'الموعد',
                      value: order.scheduledAt,
                    ),
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      label: 'السعر / الدفع',
                      value:
                          '${order.price.toStringAsFixed(0)} ر.س • ${order.paymentLabel}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _Actions(order: order, snack: _snack),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final OrderModel order;
  final void Function(BuildContext, String) snack;

  const _Actions({required this.order, required this.snack});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersCubit>();
    final children = <Widget>[];

    if (order.canStart) {
      children.add(_FilledButton(
        label: 'بدء التنفيذ',
        icon: Icons.play_arrow_rounded,
        onTap: () async {
          final ok = await cubit.startOrder(order.id);
          if (context.mounted) {
            snack(context, ok ? 'تم بدء تنفيذ الطلب' : 'تعذّر بدء الطلب، حاول مجدداً');
          }
        },
      ));
    }

    if (order.canComplete) {
      children.add(_FilledButton(
        label: 'إنهاء الطلب',
        icon: Icons.check_rounded,
        onTap: () async {
          final ok = await cubit.completeOrder(order.id);
          if (context.mounted) {
            snack(context, ok ? 'تم إنهاء الطلب' : 'تعذّر إنهاء الطلب، حاول مجدداً');
          }
        },
      ));
    }

    // تفاصيل ميدانية للميكانيكي (صيانة/طريق/سحب)
    if (order.kind.hasFieldDetails &&
        order.status != OrderStatus.pending &&
        order.status != OrderStatus.cancelled) {
      children.add(_OutlinedButton(
        label: 'تفاصيل ${order.kind.label}',
        icon: Icons.assignment_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderServiceDetailPage(
              kind: order.kind,
              orderId: order.id,
            ),
          ),
        ),
      ));
    }

    final cashPayment = order.cashPendingPayment;
    if (order.needsCashConfirmation && cashPayment != null) {
      children.add(_FilledButton(
        label: 'تأكيد استلام النقد',
        icon: Icons.attach_money_rounded,
        color: AppColors.successColor,
        onTap: () async {
          final ok = await cubit.confirmCash(
            orderId: order.id,
            paymentId: cashPayment.id,
          );
          if (context.mounted) {
            snack(
              context,
              ok
                  ? 'تم تأكيد استلام المبلغ النقدي'
                  : 'تعذّر تأكيد النقد، حاول مجدداً',
            );
          }
        },
      ));
    }

    if (order.status == OrderStatus.completed &&
        !order.needsCashConfirmation &&
        children.isEmpty) {
      return _CompletedBanner();
    }

    return Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          children[i],
        ],
      ],
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.successColor),
          const SizedBox(width: 8),
          Text(
            'تم إكمال هذا الطلب',
            style: TextStyles.Size15
                .withColor(AppColors.successColor)
                .withWeight(FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final OrderModel order;
  const _HeaderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(order.kind.icon, color: AppColors.surfaceWhite, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.serviceName,
                  style: TextStyles.Size18
                      .withColor(AppColors.surfaceWhite)
                      .withWeight(FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  order.status.label,
                  style: TextStyles.Size15.withColor(
                    AppColors.surfaceWhite.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// خط زمني بسيط لحالة الطلب: مُسند → قيد التنفيذ → مكتمل
class _StatusTimeline extends StatelessWidget {
  final OrderStatus status;
  const _StatusTimeline({required this.status});

  static const _steps = [
    OrderStatus.assigned,
    OrderStatus.inProgress,
    OrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexOf(status);
    // للطلبات الملغاة/المعلّقة نعرض الحالة كنص فقط.
    final effectiveIndex = currentIndex == -1 ? 0 : currentIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            _StepDot(
              label: _steps[i].label,
              done: i <= effectiveIndex && currentIndex != -1,
            ),
            if (i < _steps.length - 1)
              Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: (i < effectiveIndex && currentIndex != -1)
                      ? AppColors.primaryBlue
                      : AppColors.borderGrey,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool done;
  const _StepDot({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done ? AppColors.primaryBlue : AppColors.borderGrey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check : Icons.circle,
            size: 14,
            color: AppColors.surfaceWhite,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyles.Size10.withColor(
              done ? AppColors.primaryBlue : AppColors.coolGrey,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _SectionCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.Size15
                .withColor(AppColors.darkBlueBlack)
                .withWeight(FontWeight.bold),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyles.Size10.withColor(AppColors.coolGrey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyles.Size15
                    .withColor(AppColors.darkBlueBlack)
                    .withWeight(FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _FilledButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primaryBlue,
          foregroundColor: AppColors.surfaceWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, color: AppColors.surfaceWhite),
        label: Text(
          label,
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlinedButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, color: AppColors.primaryBlue),
        label: Text(
          label,
          style: TextStyles.Size15
              .withColor(AppColors.primaryBlue)
              .withWeight(FontWeight.bold),
        ),
      ),
    );
  }
}
