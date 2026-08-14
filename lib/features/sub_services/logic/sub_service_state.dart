

import 'package:car_care_plus/features/service_details/data/models/subservice_model.dart';

abstract class SubServiceState {}

/// الحالة الابتدائية
class SubServiceInitialState extends SubServiceState {}

/// حالة تحميل الخدمات الفرعية من السيرفر
class SubServiceLoadingState extends SubServiceState {}

/// حالة نجاح جلب الخدمات الفرعية
class SubServiceSuccessState extends SubServiceState {
  final List<SubServiceModel> subServices;

  SubServiceSuccessState(this.subServices);
}

/// حالة حدوث خطأ أثناء جلب البيانات
class SubServiceErrorState extends SubServiceState {
  final String message;

  SubServiceErrorState(this.message);
}

/// حالة تحدث عند تحديد أو إلغاء تحديد خدمة فرعية من قبل المستخدم
class SubServiceSelectionChangedState extends SubServiceState {
  final List<SubServiceModel> selectedSubServices;

  SubServiceSelectionChangedState(this.selectedSubServices);
}