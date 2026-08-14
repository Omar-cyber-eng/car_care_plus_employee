import 'package:car_care_plus/features/auth/presentation/forgotPasswordPage.dart';
import 'package:car_care_plus/features/auth/presentation/resetPasswordPage.dart';
import 'package:car_care_plus/features/auth/presentation/welcome_page.dart';
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

      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case Routes.resetPassword:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: email),
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
