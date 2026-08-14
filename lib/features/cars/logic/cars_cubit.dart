import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/car_model.dart';
import '../data/repos/cars_repo.dart';
import 'cars_state.dart';

class CarsCubit extends Cubit<CarsState> {
  final CarsRepo _carsRepo;

  CarsCubit(this._carsRepo) : super(CarsInitialState());

  List<CarModel> cars = [];
  CarModel? selectedCar;

  /// جلب قائمة جميع سيارات المستخدم
  Future<void> getUserCars() async {
    emit(CarsLoadingState());
    try {
      cars = await _carsRepo.getUserCars();
      emit(CarsSuccessState(cars));
    } catch (error) {
      emit(CarsErrorState(error.toString()));
    }
  }

  /// جلب تفاصيل سيارة محددة
  Future<void> getCarDetails(int carId) async {
    emit(CarDetailsLoadingState());
    try {
      selectedCar = await _carsRepo.getCarDetails(carId);
      emit(CarDetailsSuccessState(selectedCar!));
    } catch (error) {
      emit(CarsErrorState(error.toString()));
    }
  }

  /// إضافة سيارة جديدة
 Future<void> addCar({
  required Map<String, dynamic> carData,
  String? imagePath,
}) async {
  emit(AddCarLoadingState());
  try {
    final newCar = await _carsRepo.addCar(
      carData: carData,
      imagePath: imagePath,
    );
    
    // إعادة جلب السيارات الحديثة فوراً لتحديث القائمة بنفس كائنات البيانات القادمة من الباك إند
    await getUserCars();
    
    emit(AddCarSuccessState(newCar));
  } catch (error) {
    emit(CarsErrorState(error.toString()));
  }
}

  /// تعديل بيانات سيارة
 Future<void> updateCar({
  required int carId,
  required Map<String, dynamic> carData,
  File? imageFile,
}) async {
  emit(UpdateCarLoadingState());
  try {
    // 1. استقبال كائن السيارة المحدث القادم من السيرفر
    final updatedCar = await _carsRepo.updateCar(
      carId: carId,
      carData: carData,
      imageFile: imageFile,
    );

    // 2. البحث عن مكان السيارة في القائمة
    final index = cars.indexWhere((c) => c.id == carId);
    if (index != -1) {
      // 3. تحديث الكائن داخل القائمة
      cars[index] = updatedCar;
    }
    
    selectedCar = updatedCar;

    // 4. إرسال حالة النجاح لزر الحفظ وإغلاق الشاشة
    emit(UpdateCarSuccessState(updatedCar));

    // 5. إرسال قائمة السيارات المحدثة مع مصفوفة جديدة لضمان اعادة بناء الواجهة (Rebuild)
    emit(CarsSuccessState(List.from(cars)));

  } catch (error) {
    emit(CarsErrorState(error.toString()));
  }
}
  /// حذف سيارة
  Future<void> deleteCar(int carId) async {
    emit(DeleteCarLoadingState());
    try {
      await _carsRepo.deleteCar(carId);
      cars.removeWhere((c) => c.id == carId);
      emit(DeleteCarSuccessState(carId));
      emit(CarsSuccessState(cars));
    } catch (error) {
      emit(CarsErrorState(error.toString()));
    }
  }
}