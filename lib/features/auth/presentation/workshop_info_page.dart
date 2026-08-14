import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/core/validatiors/app_validators.dart';
import 'package:car_care_plus/core/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_state.dart';
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
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  void _submitWorkshop() {
    if (_formKey.currentState!.validate()) {
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
            latitude: _latitudeController.text.trim(),
            longitude: _longitudeController.text.trim(),
          );
    }
  }

  // تحقّق من الإحداثيات (رقم عشري ضمن المدى الجغرافي)
  String? _validateCoordinate(
    String? value, {
    required double min,
    required double max,
  }) {
    final requiredError = AppValidators.required(value);
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());
    if (parsed == null) return 'أدخل رقماً صحيحاً';
    if (parsed < min || parsed > max) {
      return 'القيمة يجب أن تكون بين $min و $max';
    }
    return null;
  }

  @override
  void dispose() {
    _workshopNameController.dispose();
    _workshopNameArController.dispose();
    _workshopAddressController.dispose();
    _workshopCityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
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

                  // الإحداثيات (إلزامية حسب الباك-إند)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _latitudeController,
                          label: 'خط العرض (Latitude)',
                          icon: Icons.my_location_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.\-]'),
                            ),
                          ],
                          validator: (v) =>
                              _validateCoordinate(v, min: -90, max: 90),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _longitudeController,
                          label: 'خط الطول (Longitude)',
                          icon: Icons.explore_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.\-]'),
                            ),
                          ],
                          validator: (v) =>
                              _validateCoordinate(v, min: -180, max: 180),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'تجدها في تطبيق الخرائط بالضغط المطوّل على موقع الورشة',
                      style: TextStyles.Size10.withColor(
                        AppColors.surfaceWhite.withOpacity(0.7),
                      ),
                    ),
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
