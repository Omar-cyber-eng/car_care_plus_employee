import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/core/validatiors/app_validators.dart';
import 'package:car_care_plus/core/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/core/routing/app_routes.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_state.dart';
import 'package:car_care_plus/features/auth/presentation/company_info_page.dart';
import 'package:car_care_plus/features/auth/presentation/widgets/account_type_toggle.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  AccountType _accountType = AccountType.individual;

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().registerCustomer(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
            passwordConfirmation: _confirmPasswordController.text.trim(),
          );
    }
  }

  // حساب شركة: ننتقل لصفحة استكمال البيانات مع الاحتفاظ بالحقول المشتركة
  void _goToCompanyInfo() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompanyInfoPage(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
            passwordConfirmation: _confirmPasswordController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
          'إنشاء حساب جديد',
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
                  const SizedBox(height: 10),

                  // مبدّل نوع الحساب في رأس الصفحة
                  AccountTypeToggle(
                    value: _accountType,
                    onChanged: (type) => setState(() => _accountType = type),
                  ),

                  const SizedBox(height: 16),

                  // الشعار
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
                    "أهلاً بك معنا!",
                    style: TextStyles.Size24
                        .withColor(AppColors.surfaceWhite)
                        .withWeight(FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "قم بإنشاء حسابك للاستفادة من جميع الخدمات",
                    style: TextStyles.Size15.withColor(
                      AppColors.surfaceWhite.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // حقل الاسم الكامل
                  CustomTextField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    icon: Icons.person_outline,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 16),

                  // حقل البريد الإلكتروني
                  CustomTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email,
                  ),
                  const SizedBox(height: 16),

                  // حقل رقم الهاتف
                  CustomTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 16),

                  // حقل كلمة المرور
                  CustomTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: AppValidators.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.darkBlueBlack.withOpacity(0.6),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // حقل تأكيد كلمة المرور
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    icon: Icons.lock_reset_outlined,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      final requiredError = AppValidators.required(value);
                      if (requiredError != null) return requiredError;

                      if (value != _passwordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.darkBlueBlack.withOpacity(0.6),
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // زر إنشاء الحساب
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      // تدفّق الشركة تتم معالجته في صفحة معلومات الشركة
                      if (_accountType != AccountType.individual) return;
                      if (state is AuthSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إنشاء الحساب بنجاح!'),
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
                          onPressed: state is AuthLoading
                              ? null
                              : (_accountType == AccountType.individual
                                  ? _register
                                  : _goToCompanyInfo),
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
                                  _accountType == AccountType.individual
                                      ? 'إنشاء حساب'
                                      : 'التالي',
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