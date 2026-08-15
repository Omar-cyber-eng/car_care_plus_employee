import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/gps_repo.dart';

// متتبّع موقع خفيف: يرسل نقاط GPS (POST /gps-logs) دورياً أثناء تنفيذ الطلب.
// إرسال فقط (لا قراءة)، وأفضل جهد — يتجاهل الأخطاء بصمت.
class GpsTracker extends StatefulWidget {
  final int orderId;
  final bool active; // true عندما تكون حالة الطلب in_progress

  const GpsTracker({super.key, required this.orderId, required this.active});

  @override
  State<GpsTracker> createState() => _GpsTrackerState();
}

class _GpsTrackerState extends State<GpsTracker> {
  static const _interval = Duration(seconds: 30);

  final _repo = GpsRepo(ApiService());
  Timer? _timer;
  bool _tracking = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(GpsTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _start();
    if (!widget.active && oldWidget.active) _stop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final ok = await _ensurePermission();
    if (!ok || !mounted || !widget.active) return;
    setState(() => _tracking = true);
    _sendOnce();
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _sendOnce());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _tracking = false);
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _sendOnce() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      await _repo.logPoint(
        latitude: pos.latitude,
        longitude: pos.longitude,
        orderId: widget.orderId,
      );
    } catch (_) {
      // أفضل جهد — نتجاهل بصمت (تعذّر تحديد الموقع أو إرساله).
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_tracking) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location_rounded,
              size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'يتم إرسال موقعك للورشة أثناء تنفيذ الطلب',
              style: TextStyles.Size10
                  .withColor(AppColors.primaryBlue)
                  .withWeight(FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
