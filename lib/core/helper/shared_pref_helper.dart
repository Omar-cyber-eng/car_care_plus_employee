

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPrefKeys {
  static const String userToken = 'user_token';
}

class SharedPrefHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// حفظ التوكن مشفراً
  static Future<void> setSecuredString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// قراءة التوكن المشفر
  static Future<String> getSecuredString(String key) async {
    return await _storage.read(key: key) ?? '';
  }

  /// مسح التوكن عند تسجيل الخروج
  static Future<void> deleteSecuredString(String key) async {
    await _storage.delete(key: key);
  }
}