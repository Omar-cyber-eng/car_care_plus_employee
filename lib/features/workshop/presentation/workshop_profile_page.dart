import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/core/validatiors/app_validators.dart';
import 'package:car_care_plus/core/widgets/customTextField.dart';
import 'package:car_care_plus/features/auth/presentation/location_picker_page.dart';
import 'package:car_care_plus/features/workshop/data/workshop_model.dart';
import 'package:car_care_plus/features/workshop/data/workshop_repo.dart';

// ملف الورشة (دور workshop): عرض بيانات ورشتي + تعديلها.
class WorkshopProfilePage extends StatefulWidget {
  const WorkshopProfilePage({super.key});

  @override
  State<WorkshopProfilePage> createState() => _WorkshopProfilePageState();
}

class _WorkshopProfilePageState extends State<WorkshopProfilePage> {
  final _repo = WorkshopRepo(ApiService());
  WorkshopModel? _workshop;
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
      final workshop = await _repo.getMyWorkshop();
      if (mounted) setState(() => _workshop = workshop);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEdit(WorkshopModel workshop) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkshopEditPage(workshop: workshop),
      ),
    );
    if (updated == true) _load();
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
          'ملف الورشة',
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
        actions: [
          if (_workshop != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _openEdit(_workshop!),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : _error != null
              ? _errorView()
              : _content(_workshop!),
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

  Widget _content(WorkshopModel w) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.home_repair_service_rounded,
                  color: AppColors.surfaceWhite, size: 44),
              const SizedBox(height: 12),
              Text(
                w.nameAr.isNotEmpty ? w.nameAr : w.name,
                style: TextStyles.Size24
                    .withColor(AppColors.surfaceWhite)
                    .withWeight(FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pill(Icons.verified_outlined, w.statusLabel),
                  const SizedBox(width: 8),
                  _pill(Icons.star_rounded, w.ratingAvg),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _tile(Icons.badge_outlined, 'الاسم (إنجليزي)', w.name),
        _tile(Icons.location_city_outlined, 'المدينة', w.city),
        _tile(Icons.location_on_outlined, 'العنوان', w.address),
        _tile(
          Icons.my_location_outlined,
          'الإحداثيات',
          '${w.latitude}, ${w.longitude}',
        ),
      ],
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.surfaceWhite),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyles.Size10
                .withColor(AppColors.surfaceWhite)
                .withWeight(FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
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
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyles.Size10.withColor(AppColors.coolGrey)),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyles.Size15
                      .withColor(AppColors.darkBlueBlack)
                      .withWeight(FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// شاشة تعديل الورشة — تعيد true عند نجاح الحفظ.
class WorkshopEditPage extends StatefulWidget {
  final WorkshopModel workshop;

  const WorkshopEditPage({super.key, required this.workshop});

  @override
  State<WorkshopEditPage> createState() => _WorkshopEditPageState();
}

class _WorkshopEditPageState extends State<WorkshopEditPage> {
  final _repo = WorkshopRepo(ApiService());
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  LatLng? _location;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final w = widget.workshop;
    _nameController = TextEditingController(text: w.name);
    _nameArController = TextEditingController(text: w.nameAr);
    _cityController = TextEditingController(text: w.city);
    _addressController = TextEditingController(text: w.address);
    final lat = double.tryParse(w.latitude);
    final lng = double.tryParse(w.longitude);
    if (lat != null && lng != null) _location = LatLng(lat, lng);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initialLocation: _location),
      ),
    );
    if (result != null) setState(() => _location = result);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_location == null) {
      _snack('حدّد موقع الورشة على الخريطة', AppColors.errorColor);
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.updateWorkshop(
        id: widget.workshop.id,
        name: _nameController.text.trim(),
        nameAr: _nameArController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        latitude: _location!.latitude.toStringAsFixed(7),
        longitude: _location!.longitude.toStringAsFixed(7),
      );
      if (!mounted) return;
      _snack('تم حفظ التعديلات', AppColors.successColor);
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) _snack('تعذّر الحفظ، حاول مجدداً', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
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
        centerTitle: true,
        title: Text(
          'تعديل الورشة',
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            CustomTextField(
              controller: _nameArController,
              label: 'اسم الورشة (عربي)',
              icon: Icons.storefront_outlined,
              validator: AppValidators.required,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              label: 'اسم الورشة (إنجليزي)',
              icon: Icons.storefront_outlined,
              validator: AppValidators.required,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _cityController,
              label: 'المدينة',
              icon: Icons.location_city_outlined,
              validator: AppValidators.required,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _addressController,
              label: 'العنوان',
              icon: Icons.location_on_outlined,
              validator: AppValidators.required,
            ),
            const SizedBox(height: 16),
            _locationField(),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.surfaceWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _saving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.save_outlined),
                label: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.surfaceWhite,
                        ),
                      )
                    : Text(
                        'حفظ التعديلات',
                        style: TextStyles.Size18
                            .withColor(AppColors.surfaceWhite)
                            .withWeight(FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationField() {
    final loc = _location;
    return Material(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _pickLocation,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'موقع الورشة على الخريطة',
                      style: TextStyles.Size15
                          .withColor(AppColors.darkBlueBlack)
                          .withWeight(FontWeight.w600),
                    ),
                    if (loc != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${loc.latitude.toStringAsFixed(6)}, '
                        '${loc.longitude.toStringAsFixed(6)}',
                        style: TextStyles.Size10.withColor(AppColors.coolGrey),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.edit_location_alt_outlined,
                  color: AppColors.primaryBlue, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
