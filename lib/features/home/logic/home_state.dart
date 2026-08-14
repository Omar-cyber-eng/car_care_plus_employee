import '../data/models/category_model.dart';
import '../data/models/service_model.dart';

abstract class HomeState {}

class HomeInitialState extends HomeState {}

// حالات جلب التصنيفات والخدمات الأولية
class HomeLoadingState extends HomeState {}

class HomeSuccessState extends HomeState {
  final List<CategoryModel> categories;
  final List<ServiceModel> services;
  final int? selectedCategoryId;

  HomeSuccessState({
    required this.categories,
    required this.services,
    this.selectedCategoryId,
  });
}

class HomeErrorState extends HomeState {
  final String message;
  HomeErrorState(this.message);
}

// حالة تحميل وتحديث الخدمات عند تغيير التصنيف
class ServicesLoadingState extends HomeState {}