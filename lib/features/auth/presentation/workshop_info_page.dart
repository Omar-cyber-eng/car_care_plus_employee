import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/core/validatiors/app_validators.dart';
import 'package:car_care_plus/core/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_state.dart';
import 'package:car_care_plus/features/auth/presentation/location_picker_page.dart';
import 'package:car_care_plus/features/auth/presentation/pending_approval_page.dart';

class WorkshopInfoPage extends StatefulWidget {
  // بيانات المسؤول القادمة من صفحة إنشاء الحساب
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  const WorkshopInfoPage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  State<WorkshopInfoPage> createState() => _WorkshopInfoPageState();
}

class _WorkshopInfoPageState extends State<WorkshopInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _workshopNameController = TextEditingController();
  final TextEditingController _workshopNameArController =
      TextEditingController();
  final TextEditingController _workshopAddressController =
      TextEditingController();
  final TextEditingController _workshopCityController = TextEditingController();

  // موقع الورشة المُختار من الخريطة (إلزامي).
  LatLng? _selectedLocation;

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initialLocation: _selectedLocation),
      ),
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
    }
  }

  void _submitWorkshop() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد موقع الورشة على الخريطة'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    context.read<AuthCubit>().registerWorkshop(
          name: widget.name,
          email: widget.email,
          phone: widget.phone,
          password: widget.password,
          passwordConfirmation: widget.passwordConfirmation,
          workshopName: _workshopNameController.text.trim(),
          workshopNameAr: _workshopNameArController.text.trim(),
          workshopAddress: _workshopAddressController.text.trim(),
          workshopCity: _workshopCityController.text.trim(),
          latitude: _selectedLocation!.latitude.toStringAsFixed(7),
          longitude: _selectedLocation!.longitude.toStringAsFixed(7),
        );
  }

  @override
  void dispose() {
    _workshopNameController.dispose();
    _workshopNameArController.dispose();
    _workshopAddressController.dispose();
    _workshopCityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'معلومات الورشة',
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surfaceWhite),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.mainAppGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.home_repair_service_rounded,
                      color: AppColors.surfaceWhite,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "بيانات الورشة",
                    style: TextStyles.Size24
                        .withColor(AppColors.surfaceWhite)
                        .withWeight(FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "أكمل معلومات ورشتك لتقديم طلب التسجيل",
                    style: TextStyles.Size15.withColor(
                      AppColors.surfaceWhite.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  CustomTextField(
                    controller: _workshopNameController,
                    label: 'اسم الورشة (بالإنجليزية)',
                    icon: Icons.storefront_outlined,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _workshopNameArController,
                    label: 'اسم الورشة (بالعربية)',
                    icon: Icons.storefront_outlined,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _workshopCityController,
                    label: 'المدينة',
                    icon: Icons.location_city_outlined,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _workshopAddressController,
                    label: 'عنوان الورشة',
                    icon: Icons.location_on_outlined,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 16),

                  // موقع الورشة على الخريطة (إلزامي)
                  _LocationField(
                    location: _selectedLocation,
                    onTap: _pickLocation,
                  ),

                  const SizedBox(height: 28),

                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        // تسجيل الورشة معلّق (بلا توكن) — ننتقل لشاشة "قيد المراجعة"
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PendingApprovalPage(),
                          ),
                          (route) => false,
                        );
                      } else if (state is AuthFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage),
                            backgroundColor: AppColors.errorColor,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return Container(
                        width: double.infinity,
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
                        child: ElevatedButton(
                          onPressed:
                              state is AuthLoading ? null : _submitWorkshop,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: AppColors.surfaceWhite,
                                )
                              : Text(
                                  'تقديم طلب التسجيل',
                                  style: TextStyles.Size18
                                      .withColor(AppColors.surfaceWhite)
                                      .withWeight(FontWeight.bold),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// حقل اختيار الموقع: زر يفتح الخريطة، ويعرض الإحداثيات بعد الاختيار.
class _LocationField extends StatelessWidget {
  final LatLng? location;
  final VoidCallback onTap;

  const _LocationField({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasLocation = location != null;

    return Material(
      color: AppColors.surfaceWhite.withOpacity(0.92),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(
                hasLocation
                    ? Icons.check_circle_rounded
                    : Icons.add_location_alt_outlined,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLocation
                          ? 'تم تحديد موقع الورشة'
                          : 'تحديد موقع الورشة على الخريطة',
                      style: TextStyles.Size15
                          .withColor(AppColors.darkBlueBlack)
                          .withWeight(FontWeight.w600),
                    ),
                    if (hasLocation) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${location!.latitude.toStringAsFixed(6)}, '
                        '${location!.longitude.toStringAsFixed(6)}',
                        style: TextStyles.Size10.withColor(AppColors.coolGrey),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                hasLocation ? Icons.edit_location_alt_outlined : Icons.map_outlined,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
