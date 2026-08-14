import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/core/validatiors/app_validators.dart';
import 'package:car_care_plus/core/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/core/routing/app_routes.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_state.dart';

class CompanyInfoPage extends StatefulWidget {
  // البيانات المشتركة القادمة من صفحة إنشاء الحساب
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  const CompanyInfoPage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  State<CompanyInfoPage> createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyNameArController = TextEditingController();
  final TextEditingController _commercialRegController = TextEditingController();
  final TextEditingController _taxNumberController = TextEditingController();
  final TextEditingController _companyAddressController =
      TextEditingController();

  void _createCompany() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().registerCompany(
            name: widget.name,
            email: widget.email,
            phone: widget.phone,
            password: widget.password,
            passwordConfirmation: widget.passwordConfirmation,
            companyName: _companyNameController.text.trim(),
            companyNameAr: _companyNameArController.text.trim(),
            commercialReg: _commercialRegController.text.trim(),
            taxNumber: _taxNumberController.text.trim(),
            companyAddress: _companyAddressController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyNameArController.dispose();
    _commercialRegController.dispose();
    _taxNumberController.dispose();
    _companyAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'معلومات الشركة',
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
                      Icons.business_rounded,
                      color: AppColors.surfaceWhite,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "بيانات الشركة",
                    style: TextStyles.Size24
                        .withColor(AppColors.surfaceWhite)
                        .withWeight(FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "أكمل معلومات شركتك لإتمام التسجيل",
                    style: TextStyles.Size15.withColor(
                      AppColors.surfaceWhite.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 28),

                  CustomTextField(
                    controller: _companyNameController,
                    label: 'اسم الشركة (بالإنجليزية)',
                    icon: Icons.business_outlined,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _companyNameArController,
                    label: 'اسم الشركة (بالعربية)',
                    icon: Icons.business_outlined,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _commercialRegController,
                    label: 'رقم السجل التجاري',
                    icon: Icons.assignment_outlined,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _taxNumberController,
                    label: 'الرقم الضريبي',
                    icon: Icons.receipt_long_outlined,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _companyAddressController,
                    label: 'عنوان الشركة',
                    icon: Icons.location_on_outlined,
                    validator: AppValidators.required,
                  ),

                  const SizedBox(height: 32),

                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إنشاء حساب الشركة بنجاح!'),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.mainLayout,
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
                              state is AuthLoading ? null : _createCompany,
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
                                  'إنشاء حساب الشركة',
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
