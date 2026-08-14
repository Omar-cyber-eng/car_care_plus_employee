import '../data/models/car_model.dart';

abstract class CarsState {}

class CarsInitialState extends CarsState {}

// حالات جلب قائمة السيارات
class CarsLoadingState extends CarsState {}

class CarsSuccessState extends CarsState {
  final List<CarModel> cars;
  CarsSuccessState(this.cars);
}

class CarsErrorState extends CarsState {
  final String message;
  CarsErrorState(this.message);
}

// حالات جلب تفاصيل سيارة واحدة
class CarDetailsLoadingState extends CarsState {}

class CarDetailsSuccessState extends CarsState {
  final CarModel car;
  CarDetailsSuccessState(this.car);
}

// حالات إضافة سيارة جديدة
class AddCarLoadingState extends CarsState {}

class AddCarSuccessState extends CarsState {
  final CarModel car;
  AddCarSuccessState(this.car);
}

// حالات تعديل سيارة
class UpdateCarLoadingState extends CarsState {}

class UpdateCarSuccessState extends CarsState {
  final CarModel car;
  UpdateCarSuccessState(this.car);
}

// حالات حذف سيارة
class DeleteCarLoadingState extends CarsState {}

class DeleteCarSuccessState extends CarsState {
  final int carId;
  DeleteCarSuccessState(this.carId);
}