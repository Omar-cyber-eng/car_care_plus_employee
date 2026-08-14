import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyles {
  // تحويلها إلى Getters تضمن حساب القيمة الصحيحة لحظة استدعائها وليس عند تحميل الكلاس
  static TextStyle get Size32 => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle get Size28 => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        height: 1.25,
      );

  static TextStyle get Size24 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get Size18 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  static TextStyle get Size15 => TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  static TextStyle get Size10 => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );
}

// ==================== Extension لتسهيل التخصيص ====================

extension TextStyleHelper on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size.sp);
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);
  TextStyle withLetterSpacing(double spacing) => copyWith(letterSpacing: spacing);
  TextStyle withHeight(double height) => copyWith(height: height);
  TextStyle withDecoration(TextDecoration decoration) => copyWith(decoration: decoration);
  TextStyle withBackground(Color color) => copyWith(backgroundColor: color);
  TextStyle withShadows(List<Shadow> shadows) => copyWith(shadows: shadows);
}