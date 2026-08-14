// lib/features/auth/presentation/pages/forgot_password_page.dart

import 'package:car_care_plus/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/resources/app_color.dart'; //[cite: 7]
import 'package:car_care_plus/core/resources/text_style.dart'; //[cite: 8]
import 'package:car_care_plus/core/validatiors/app_validators.dart';
import 'package:car_care_plus/core/widgets/customTextField.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().sendResetOtp(
        email: _emailController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'استعادة كلمة المرور',
          style: TextStyles.Size18.withColor(
            AppColors.surfaceWhite,
          ).withWeight(FontWeight.bold), //[cite: 7, 8]
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.surfaceWhite,
        ), //[cite: 7]
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.mainAppGradient,
        ), //[cite: 7]
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
                      backgroundColor: AppColors.surfaceWhite.withOpacity(
                        0.15,
                      ), //[cite: 7]
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 55.sp,
                        color: AppColors.cyanAccent, //[cite: 7]
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      "نسيت كلمة المرور؟",
                      style: TextStyles.Size24.withColor(
                        AppColors.surfaceWhite,
                      ).withWeight(FontWeight.bold), //[cite: 7, 8]
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "أدخل البريد الإلكتروني المرتبط بحسابك وستصلك رسالة تحتوي على رمز التحقق (OTP)",
                      textAlign: TextAlign.center,
                      style: TextStyles.Size15.withColor(
                        AppColors.surfaceWhite.withOpacity(0.8),
                      ), //[cite: 7, 8]
                    ),
                    SizedBox(height: 32.h),
                    CustomTextField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.required,
                    ),
                    SizedBox(height: 32.h),
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is SendOtpSuccess) {
                          //[cite: 6]
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor:
                                  AppColors.successColor, //[cite: 7]
                            ),
                          );
                          // الانتقال لشاشة إدخال הـ OTP وكلمة المرور الجديدة
                          Navigator.pushNamed(context,Routes.resetPassword,arguments: _emailController.text.trim(),);

                        } else if (state is AuthFailure) {
                          //[cite: 6]
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
                                color: AppColors.primaryBlue.withOpacity(
                                  0.4,
                                ), //[cite: 7]
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : _sendOtp, //[cite: 6]
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child:
                                state
                                    is AuthLoading //[cite: 6]
                                ? const CircularProgressIndicator(
                                    color: AppColors.surfaceWhite,
                                  ) //[cite: 7]
                                : Text(
                                    'إرسال رمز التحقق',
                                    style:
                                        TextStyles.Size18.withColor(
                                          AppColors.surfaceWhite,
                                        ).withWeight(
                                          FontWeight.bold,
                                        ), //[cite: 7, 8]
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
