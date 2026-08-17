import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/widgets/gradient_header.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';
import 'package:car_care_plus/features/orders/data/orders_repo.dart';
import 'package:car_care_plus/features/orders/logic/orders_cubit.dart';
import 'package:car_care_plus/features/orders/logic/orders_state.dart';
import 'package:car_care_plus/features/orders/presentation/order_details_page.dart';
import 'package:car_care_plus/features/orders/presentation/widgets/order_card.dart';
import 'package:car_care_plus/features/notifications/data/notifications_repo.dart';
import 'package:car_care_plus/features/notifications/presentation/notifications_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // null = الكل. وإلا نفلتر حسب الحالة.
  OrderStatus? _filter;

  // الحالات التي يهتم بها الموظف/الورشة.
  static const List<OrderStatus?> _filters = [
    null,
    OrderStatus.assigned,
    OrderStatus.inProgress,
    OrderStatus.completed,
  ];

  String _filterLabel(OrderStatus? f) => f == null ? 'الكل' : f.label;

  late final OrdersCubit _cubit;
  final NotificationsRepo _notifRepo = NotificationsRepo(ApiService());
  Timer? _pollTimer;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _cubit = OrdersCubit(OrdersRepo(ApiService()))..loadOrders();
    _refreshUnread();
    // استطلاع دوري صامت: الطلبات + عدّاد الإشعارات (بديل push غير المفعّل).
    _pollTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      _cubit.refreshSilently();
      _refreshUnread();
    });
  }

  Future<void> _refreshUnread() async {
    try {
      final count = await _notifRepo.getUnreadCount();
      if (mounted) setState(() => _unread = count);
    } catch (_) {}
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    ).then((_) => _refreshUnread());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.lightBlueSurface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GradientHeader(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الطلبات',
                          style: TextStyles.Size24
                              .withColor(AppColors.surfaceWhite)
                              .withWeight(FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الطلبات المسندة إليك وحالتها',
                          style: TextStyles.Size15.withColor(
                            AppColors.surfaceWhite.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _NotificationBell(count: _unread, onTap: _openNotifications),
                ],
              ),
            ),
            _buildFilters(),
            Expanded(
              child: BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    );
                  }

                  if (state is OrdersError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () => context.read<OrdersCubit>().loadOrders(),
                    );
                  }

                  if (state is OrdersLoaded) {
                    final orders = _filter == null
                        ? state.orders
                        : state.orders
                            .where((o) => o.status == _filter)
                            .toList();

                    return RefreshIndicator(
                      color: AppColors.primaryBlue,
                      onRefresh: () => context.read<OrdersCubit>().loadOrders(),
                      child: orders.isEmpty
                          ? _emptyList()
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                              itemCount: orders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return OrderCard(
                                  order: order,
                                  onTap: () => _openDetails(context, order.id),
                                );
                              },
                            ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, int orderId) {
    final cubit = context.read<OrdersCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: OrderDetailsPage(orderId: orderId),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = _filters[index];
          final selected = f == _filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBlue : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Text(
                _filterLabel(f),
                style: TextStyles.Size10
                    .withColor(
                      selected ? AppColors.surfaceWhite : AppColors.coolGrey,
                    )
                    .withWeight(FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyList() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(
          Icons.inbox_rounded,
          size: 64,
          color: AppColors.coolGrey.withOpacity(0.5),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'لا توجد طلبات في هذه الحالة',
            style: TextStyles.Size15.withColor(AppColors.coolGrey),
          ),
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NotificationBell({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.surfaceWhite,
            size: 28,
          ),
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: const BoxDecoration(
                color: AppColors.errorColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: TextStyles.Size10
                    .withColor(AppColors.surfaceWhite)
                    .withWeight(FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyles.Size15.withColor(AppColors.errorColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
