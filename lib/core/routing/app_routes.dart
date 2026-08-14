import 'package:car_care_plus/features/auth/presentation/forgotPasswordPage.dart';
import 'package:car_care_plus/features/auth/presentation/resetPasswordPage.dart';
import 'package:car_care_plus/features/auth/presentation/welcome_page.dart';
import 'package:car_care_plus/features/cars/data/models/car_model.dart'; // 👈 استيراد موديل السيارة
import 'package:car_care_plus/features/cars/ui/views/edit_car_page.dart'; // 👈 استيراد شاشة التعديل (أصلح المسار حسب مكان الملف)
import 'package:car_care_plus/features/main_layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:car_care_plus/features/auth/presentation/login_page.dart';
import 'package:car_care_plus/features/auth/presentation/register_page.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String welcome = '/welcome';
  static const String mainLayout = '/main';
  static const String forgotPassword = '/forgotPassword';
  static const String resetPassword = '/resetPassword';
  static const String editCar = '/editCar'; // 👈 1. إضافة مسار تعديل السيارة
}

class AppRouter {
  final Function(Locale)? onLanguageChanged;

  AppRouter({this.onLanguageChanged});

  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case Routes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      case Routes.mainLayout:
        return MaterialPageRoute(builder: (_) => const MainLayout());

      // 🆕 مسار طلب الـ OTP
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      // 🆕 مسار تعيين كلمة المرور (يستقبل الـ email عبر arguments)
      case Routes.resetPassword:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: email),
        );

      // 🆕 2. مسار تعديل السيارة (يستقبل كائن car من نوع CarModel عبر arguments)
      case Routes.editCar:
        final car = settings.arguments as CarModel;
        return MaterialPageRoute(
          builder: (_) => EditCarPage(car: car), // أو اسم الشاشة المخصصة لديك
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('لا يوجد مسار معرف لـ ${settings.name}')),
          ),
        );
    }
  }
}