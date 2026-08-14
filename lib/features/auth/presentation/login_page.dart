import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/core/validatiors/app_validators.dart';
import 'package:car_care_plus/core/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/core/routing/app_routes.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        email: _loginController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'تسجيل الدخول',
          style: TextStyles.Size18.withColor(
            AppColors.surfaceWhite,
          ).withWeight(FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surfaceWhite),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainAppGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // شعار التطبيق
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.black,
                      child: ClipOval(
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/logo3.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "مرحباً بعودتك!",
                      style: TextStyles.Size24.withColor(
                        AppColors.surfaceWhite,
                      ).withWeight(FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "سجل دخولك للمتابعة إلى حسابك",
                      style: TextStyles.Size15.withColor(
                        AppColors.surfaceWhite.withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // حقل البريد الإلكتروني أو الهاتف
                    CustomTextField(
                      controller: _loginController,
                      label: 'البريد الإلكتروني أو رقم الهاتف',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.required,
                    ),

                    const SizedBox(height: 16),

                    // حقل كلمة المرور
                    CustomTextField(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      validator: AppValidators.required,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.darkBlueBlack.withOpacity(0.6),
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // نسيت كلمة المرور
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.forgotPassword);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyles.Size15.withColor(
                            AppColors.surfaceWhite.withOpacity(0.9),
                          ).withWeight(FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // زر تسجيل الدخول
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم تسجيل الدخول بنجاح! مرحباً ${state.user.name}',
                              ),
                              backgroundColor: AppColors.primaryBlue,
                            ),
                          );
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.mainLayout,
                            (route) => false,
                          );
                        } else if (state is AuthFailure) {
                          // حساب الورشة يبقى غير نشط حتى يعتمده الأدمن → 403 inactive
                          final msg = state.errorMessage.toLowerCase();
                          final isInactive = msg.contains('inactive') ||
                              msg.contains('غير نشط') ||
                              msg.contains('قيد');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isInactive
                                    ? 'حسابك قيد المراجعة من الإدارة. سيتم تفعيله بعد الاعتماد.'
                                    : state.errorMessage,
                              ),
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
                            onPressed: state is AuthLoading ? null : _login,
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
                                    'تسجيل الدخول',
                                    style: TextStyles.Size18.withColor(
                                      AppColors.surfaceWhite,
                                    ).withWeight(FontWeight.bold),
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // رابط الانتقال لإنشاء حساب
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
                          style: TextStyles.Size15.withColor(
                            AppColors.surfaceWhite.withOpacity(0.8),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.register,
                            );
                          },
                          child: Text(
                            'إنشاء حساب جديد',
                            style:
                                TextStyles.Size15.withColor(
                                      AppColors.surfaceWhite,
                                    )
                                    .withWeight(FontWeight.bold)
                                    .withDecoration(TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
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
