import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/notifications/data/notification_model.dart';
import 'package:car_care_plus/features/notifications/data/notifications_repo.dart';
import 'package:car_care_plus/features/orders/data/orders_repo.dart';
import 'package:car_care_plus/features/orders/logic/orders_cubit.dart';
import 'package:car_care_plus/features/orders/presentation/order_details_page.dart';

// شاشة الإشعارات داخل التطبيق (قراءة + تعليم مقروء + انتقال للطلب المرتبط).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _repo = NotificationsRepo(ApiService());
  List<NotificationModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repo.getNotifications();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _repo.markAllRead();
    } catch (_) {}
    if (mounted) await _load();
  }

  Future<void> _onTap(NotificationModel n) async {
    if (!n.isRead) {
      try {
        await _repo.markRead(n.id);
      } catch (_) {}
    }
    if (!mounted) return;
    // انتقال حسب الكيان المرتبط (order → تفاصيل الطلب).
    if (n.referenceType == 'order' && n.referenceId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => OrdersCubit(OrdersRepo(ApiService())),
            child: OrderDetailsPage(orderId: n.referenceId!),
          ),
        ),
      );
    }
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الإشعارات',
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
        actions: [
          if (_items.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'تعليم الكل',
                style: TextStyles.Size10
                    .withColor(AppColors.surfaceWhite)
                    .withWeight(FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : _error != null
              ? _errorView()
              : _items.isEmpty
                  ? _emptyView()
                  : RefreshIndicator(
                      color: AppColors.primaryBlue,
                      onRefresh: _load,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _NotificationCard(
                          item: _items[i],
                          onTap: () => _onTap(_items[i]),
                        ),
                      ),
                    ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _error ?? 'خطأ',
            style: TextStyles.Size15.withColor(AppColors.errorColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        Icon(Icons.notifications_off_outlined,
            size: 64, color: AppColors.coolGrey.withOpacity(0.5)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'لا توجد إشعارات',
            style: TextStyles.Size15.withColor(AppColors.coolGrey),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead
          ? AppColors.surfaceWhite
          : AppColors.primaryBlue.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyles.Size15
                          .withColor(AppColors.darkBlueBlack)
                          .withWeight(FontWeight.bold),
                    ),
                    if (item.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: TextStyles.Size10.withColor(AppColors.coolGrey),
                      ),
                    ],
                    if (item.createdAt.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.createdAt,
                        style: TextStyles.Size10.withColor(
                          AppColors.coolGrey.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
