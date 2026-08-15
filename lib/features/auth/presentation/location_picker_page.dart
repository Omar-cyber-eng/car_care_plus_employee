import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// خطأ موقع مع رسالة عربية + إشارة لفتح الإعدادات عند الرفض الدائم.
class _LocationFailure implements Exception {
  final String message;
  final bool openSettings;
  _LocationFailure(this.message, {this.openSettings = false});
}

/// شاشة اختيار موقع الورشة على الخريطة.
/// تُرجع [LatLng] النقطة التي يقف عليها الدبوس عند تأكيد الموقع، أو null إن أُلغيت.
class LocationPickerPage extends StatefulWidget {
  /// موقع مبدئي (إن سبق للمستخدم اختيار موقع) — وإلا نبدأ من موقعه الحالي/الافتراضي.
  final LatLng? initialLocation;

  const LocationPickerPage({super.key, this.initialLocation});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final MapController _mapController = MapController();

  // مركز افتراضي (الرياض) إن تعذّر تحديد موقع الجهاز.
  static const LatLng _fallbackCenter = LatLng(24.7136, 46.6753);
  static const double _initialZoom = 15;

  late LatLng _target;
  bool _mapReady = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _target = widget.initialLocation ?? _fallbackCenter;
    // لو لم يُمرَّر موقع سابق، نحاول الانتقال لموقع الجهاز الحالي عند الفتح.
    if (widget.initialLocation == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToCurrentLocation());
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// يحدّد الموقع الحالي بعد التحقق من الخدمة والصلاحيات (يرمي [_LocationFailure]).
  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw _LocationFailure('خدمة الموقع (GPS) مغلقة. فعّلها ثم أعد المحاولة.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw _LocationFailure('تم رفض إذن الوصول للموقع.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw _LocationFailure(
        'إذن الموقع مرفوض دائماً. فعّله من إعدادات التطبيق.',
        openSettings: true,
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final pos = await _determinePosition();
      _target = LatLng(pos.latitude, pos.longitude);
      if (_mapReady) _mapController.move(_target, 16);
    } on _LocationFailure catch (e) {
      _showError(e);
    } catch (_) {
      _showError(_LocationFailure('تعذّر تحديد موقعك الحالي. حرّك الخريطة يدوياً.'));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showError(_LocationFailure failure) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failure.message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        action: failure.openSettings
            ? SnackBarAction(
                label: 'الإعدادات',
                textColor: AppColors.surfaceWhite,
                onPressed: Geolocator.openAppSettings,
              )
            : null,
      ),
    );
  }

  void _confirm() {
    // مركز الكاميرا = النقطة التي يقف عليها الدبوس الثابت في منتصف الشاشة.
    Navigator.pop(context, _mapController.camera.center);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1) الخريطة (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _target,
              initialZoom: _initialZoom,
              minZoom: 3,
              maxZoom: 19,
              onMapReady: () {
                _mapReady = true;
                _mapController.move(_target, _mapController.camera.zoom);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.carcareplus.employee',
              ),
            ],
          ),

          // 2) الدبوس الثابت في منتصف الشاشة (طرفه يشير للمركز)
          IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Icon(
                  Icons.location_pin,
                  size: 48,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),

          // 3) شريط علوي: رجوع + عنوان
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkBlueBlack.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'حرّك الخريطة لضبط الدبوس على موقع ورشتك',
                        style: TextStyles.Size15
                            .withColor(AppColors.darkBlueBlack)
                            .withWeight(FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4) زر موقعي الحالي
          Positioned(
            bottom: 110,
            left: 16,
            child: _CircleButton(
              icon: _locating ? null : Icons.my_location,
              loading: _locating,
              onTap: _goToCurrentLocation,
            ),
          ),

          // 5) زر تأكيد الموقع
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppColors.buttonGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.surfaceWhite,
                ),
                label: Text(
                  'تأكيد الموقع',
                  style: TextStyles.Size18
                      .withColor(AppColors.surfaceWhite)
                      .withWeight(FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onTap;
  final bool loading;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryBlue,
                  ),
                )
              : Icon(icon, color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}
