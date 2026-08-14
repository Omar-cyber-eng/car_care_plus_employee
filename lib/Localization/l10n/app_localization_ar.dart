// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localization.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get session => 'الجلسة';

  @override
  String total(Object ammount, Object amount) {
    return 'المجموع الخاص بك $amount ليرة';
  }
}
