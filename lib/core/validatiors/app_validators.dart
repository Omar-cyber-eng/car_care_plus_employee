class AppValidators {
  /// تحقق من الحقول المطلوبة العامة (عدم الفراغ)
  static String? required(String? value, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// التحقق من صحة البريد الإلكتروني
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  /// التحقق من رقم الهاتف
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (value.trim().length < 9) {
      return 'يرجى إدخال رقم هاتف صحيح (9 أرقام على الأقل)';
    }
    return null;
  }

  /// التحقق من قوة كلمة المرور
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (value.trim().length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  /// التحقق من تطابق تأكيد كلمة المرور
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (value != originalPassword) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }
}