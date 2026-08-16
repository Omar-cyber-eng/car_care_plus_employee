import 'package:flutter/material.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/order_extras_model.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';
import 'package:car_care_plus/features/orders/data/orders_repo.dart';

// سجل حالة الطلب (قراءة فقط) — GET /bookings/{id}/status-history (غسّال/ميكانيكي).
class StatusHistoryPage extends StatefulWidget {
  final int orderId;

  const StatusHistoryPage({super.key, required this.orderId});

  @override
  State<StatusHistoryPage> createState() => _StatusHistoryPageState();
}

class _StatusHistoryPageState extends State<StatusHistoryPage> {
  final _repo = OrdersRepo(ApiService());
  List<StatusHistoryEntry> _entries = [];
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
      final entries = await _repo.getStatusHistory(widget.orderId);
      if (mounted) setState(() => _entries = entries);
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
          'سجل حالة الطلب',
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
              : _entries.isEmpty
                  ? _emptyView()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      itemCount: _entries.length,
                      itemBuilder: (_, i) => _TimelineTile(
                        entry: _entries[i],
                        isLast: i == _entries.length - 1,
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
    return Center(
      child: Text(
        'لا يوجد سجل حالة',
        style: TextStyles.Size15.withColor(AppColors.coolGrey),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final StatusHistoryEntry entry;
  final bool isLast;

  const _TimelineTile({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: entry.status.color,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.borderGrey,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.status.label,
                      style: TextStyles.Size15
                          .withColor(entry.status.color)
                          .withWeight(FontWeight.bold),
                    ),
                    if (entry.changedAt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.changedAt,
                        style: TextStyles.Size10.withColor(AppColors.coolGrey),
                      ),
                    ],
                    if (entry.note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        entry.note,
                        style:
                            TextStyles.Size15.withColor(AppColors.darkBlueBlack),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
