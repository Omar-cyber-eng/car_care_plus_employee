import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/category_model.dart';
import '../data/models/service_model.dart';
import '../data/repos/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;

  HomeCubit(this._homeRepo) : super(HomeInitialState());

  List<CategoryModel> categories = [];
  List<ServiceModel> services = [];
  int? selectedCategoryId;

  /// تحميل بيانات الشاشة الرئيسية عند الفتح
 Future<void> getHomeData() async {
  if (isClosed) return;
  emit(HomeLoadingState());

  try {
    final results = await Future.wait([
      _homeRepo.getCategories(),
      _homeRepo.getServices(),
    ]);

    // التحقق مجدداً بعد انتهاء عمليات الـ await
    if (isClosed) return;

    categories = results[0] as List<CategoryModel>;
    services = results[1] as List<ServiceModel>;

    emit(HomeSuccessState(
      categories: categories,
      services: services,
      selectedCategoryId: selectedCategoryId,
    ));
  } catch (error) {
    if (isClosed) return;
    emit(HomeErrorState(error.toString()));
  }
}

  /// الفلترة حسب قسم محدد عند الضغط عليه
 Future<void> filterByCategory(int? categoryId) async {
  if (selectedCategoryId == categoryId) {
    selectedCategoryId = null; // إلغاء التحديد وعرض الكل
  } else {
    selectedCategoryId = categoryId;
  }

  emit(ServicesLoadingState());
  try {
    services = await _homeRepo.getServices(categoryId: selectedCategoryId);
    emit(HomeSuccessState(
      categories: categories,
      services: services,
      selectedCategoryId: selectedCategoryId,
    ));
  } catch (error) {
    emit(HomeErrorState(error.toString()));
  }
}
}