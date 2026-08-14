// lib/features/auth/presentation/pages/reset_password_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/resources/app_color.dart'; //[cite: 7]
import 'package:car_care_plus/core/resources/text_style.dart'; //[cite: 8]
import 'package:car_care_plus/core/validatiors/app_validators.dart';
import 'package:car_care_plus/core/widgets/customTextField.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPasswordWithOtp(
            email: widget.email,
            otp: _otpController.text.trim(),
            password: _passwordController.text.trim(),
            passwordConfirmation: _confirmPasswordController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'تعيين كلمة المرور',
          style: TextStyles.Size18.withColor(AppColors.surfaceWhite).withWeight(FontWeight.bold), //[cite: 7, 8]
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surfaceWhite), //[cite: 7]
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainAppGradient), //[cite: 7]
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: AppColors.surfaceWhite.withOpacity(0.15), //[cite: 7]
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 55.sp,
                        color: AppColors.cyanAccent, //[cite: 7]
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      "أدخل الرمز وكلمة المرور",
                      style: TextStyles.Size24.withColor(AppColors.surfaceWhite).withWeight(FontWeight.bold), //[cite: 7, 8]
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "أدخل الرمز المرسل إلى ${widget.email}",
                      textAlign: TextAlign.center,
                      style: TextStyles.Size15.withColor(AppColors.surfaceWhite.withOpacity(0.8)), //[cite: 7, 8]
                    ),
                    SizedBox(height: 32.h),

                    // حقل OTP
                    CustomTextField(
                      controller: _otpController,
                      label: 'رمز التحقق (OTP)',
                      icon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      validator: AppValidators.required,
                    ),
                    SizedBox(height: 16.h),

                    // حقل كلمة المرور الجديدة
                    CustomTextField(
                      controller: _passwordController,
                      label: 'كلمة المرور الجديدة',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      validator: AppValidators.required,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.darkBlueBlack.withOpacity(0.6), //[cite: 7]
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // حقل تأكيد كلمة المرور
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'تأكيد كلمة المرور',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        final req = AppValidators.required(value);
                        if (req != null) return req;
                        if (value != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.darkBlueBlack.withOpacity(0.6), //[cite: 7]
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is ResetPasswordSuccess) { //[cite: 6]
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppColors.successColor, //[cite: 7]
                            ),
                          );
                          // إرجاع المستخدم لصفحة تسجيل الدخول وإغلاق صفحات الاستعادة
                          Navigator.popUntil(context, (route) => route.isFirst);
                        } else if (state is AuthFailure) { //[cite: 6]
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMessage),
                              backgroundColor: AppColors.errorColor, //[cite: 7]
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Container(
                          width: double.infinity,
                          height: 55.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: AppColors.buttonGradient, //[cite: 7]
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.4), //[cite: 7]
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: state is AuthLoading ? null : _resetPassword, //[cite: 6]
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: state is AuthLoading //[cite: 6]
                                ? const CircularProgressIndicator(color: AppColors.surfaceWhite) //[cite: 7]
                                : Text(
                                    'تحديث كلمة المرور',
                                    style: TextStyles.Size18.withColor(AppColors.surfaceWhite).withWeight(FontWeight.bold), //[cite: 7, 8]
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}