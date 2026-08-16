import 'package:flutter/material.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';
import 'package:car_care_plus/features/workshop/data/workshop_repo.dart';

// سجل صيانة سيارة لدى الورشة (قراءة فقط) — GET /workshops/cars/{car}/history.
class WorkshopCarHistoryPage extends StatefulWidget {
  final int carId;

  const WorkshopCarHistoryPage({super.key, required this.carId});

  @override
  State<WorkshopCarHistoryPage> createState() => _WorkshopCarHistoryPageState();
}

class _WorkshopCarHistoryPageState extends State<WorkshopCarHistoryPage> {
  final _repo = WorkshopRepo(ApiService());
  List<OrderModel> _history = [];
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
      final history = await _repo.getCarHistory(widget.carId);
      if (mounted) setState(() => _history = history);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
          'سجل صيانة السيارة',
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : _error != null
              ? _errorView()
              : _history.isEmpty
                  ? _emptyView()
                  : RefreshIndicator(
                      color: AppColors.primaryBlue,
                      onRefresh: _load,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, i) => _HistoryCard(order: _history[i]),
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
        Icon(Icons.history_rounded,
            size: 64, color: AppColors.coolGrey.withOpacity(0.5)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'لا يوجد سجل صيانة لهذه السيارة',
            style: TextStyles.Size15.withColor(AppColors.coolGrey),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final OrderModel order;
  const _HistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(order.kind.icon, color: AppColors.primaryBlue, size: 24),
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
                  '#${order.id} • ${order.scheduledAt}',
                  style: TextStyles.Size10.withColor(AppColors.coolGrey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: order.status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyles.Size10
                      .withColor(order.status.color)
                      .withWeight(FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${order.price.toStringAsFixed(0)} ل.س',
                style: TextStyles.Size10
                    .withColor(AppColors.primaryBlue)
                    .withWeight(FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
