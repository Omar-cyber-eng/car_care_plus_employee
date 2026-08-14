import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // ألوان التطبيق المعتمدة
  static const Color primaryBlue = Color(0xFF0078FE);
  static const Color darkBlueBlack = Color(0xFF081225);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // شعار التطبيق
              Image.asset(
                'assets/images/logo4.png',
                fit: BoxFit.contain,
                height: 160, // حجم متناسق لمنع Overflows
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 80,
                    color: primaryBlue,
                  );
                },
              ),

              const SizedBox(height: 32),

              // عنوان الترحيب
              Text(
                'مرحباً بك',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: darkBlueBlack,
                ),
              ),

              const SizedBox(height: 12),

              // وصف التطبيق
              Text(
                'اكتشف خدمات العناية بالسيارات المتكاملة وسهولة الحجز وإدارة طلباتك في مكان واحد.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),

              const Spacer(flex: 3),

              // زر البدء بالتدرج الأزرق ليتناسب مع الأزرار السابقة
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [primaryBlue, Color(0xFF0052B4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // ضع أمر التنقل لصفحة تسجيل الدخول هنا لاحقاً
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ابدأ الآن',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}