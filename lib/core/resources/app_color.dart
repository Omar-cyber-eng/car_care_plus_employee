import 'package:flutter/material.dart';

abstract class AppColors {
  // ==================== الهوية اللونية الرئيسية ====================
  static const Color primaryBlue = Color(0xFF0078FE);
  static const Color darkBlueBlack = Color(0xFF081225);
  static const Color surfaceWhite = Colors.white;

static const Color darkBackground = Color(0xFF0F172A); // أسود كحلي عميق
static const Color darkCardBackground = Color(0xFF1E293B); // لون البطاقات الداكنة
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color cardShadowColor = Color(0x0C000000);
  // ==================== ألوان مشتقة ومكملة للهوية ====================
  static const Color royalBlue = Color(0xFF0052B4);
  static const Color cyanAccent = Color(0xFF00D2FF);
  static const Color lightBlueSurface = Color(0xFFF0F6FF);
  static const Color coolGrey = Color(0xFF8A99AD);
  static const Color borderGrey = Color(0xFFE2E8F0);


static const Color goldAccent = Color(0xFFFFB800);
static const Color lightGoldSurface = Color(0xFFFFF8E6);
  // ==================== ألوان الحالات والرسائل ====================
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color warningColor = Color(0xFFF1C40F);

  // ==================== التدرجات اللونية (Gradients) ====================

  // تدرج الخلفيات الشاملة
  static const LinearGradient mainAppGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, darkBlueBlack],
  );

  // تدرج الأزرار الحيوية
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryBlue, royalBlue],
  );

  // تدرج البطاقات والعروض الترويجية (VIP / Neon)
  static const LinearGradient cyanGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyanAccent, primaryBlue],
  );

  static const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [primaryBlue, Color(0xFF0052B4)],
);

static const LinearGradient headerGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF0A0E17), // أسود غامق من الأعلى
    Color(0xFF0F2042), // أزرق داكن فخم
    primaryBlue,       // أزرق التطبيق الأساسي في الأسفل
  ],
);

// تدرج بطاقات العروض الداكنة
static const LinearGradient promoCardGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF111827), // أسود من الأعلى
    Color(0xFF1E3A8A), // أزرق نيون من الأسفل
  ],
);

  // تدرج البطاقات الداكنة
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F1E38), darkBlueBlack],
  );
}
