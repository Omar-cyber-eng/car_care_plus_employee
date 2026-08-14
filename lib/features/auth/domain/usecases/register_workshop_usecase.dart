import 'package:car_care_plus/features/auth/data/user_model.dart';
import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class RegisterWorkshopUseCase {
  final AuthRepository repository;

  RegisterWorkshopUseCase(this.repository);

  Future<Either<String, UserModel>> call({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String workshopName,
    required String workshopNameAr,
    required String workshopAddress,
    required String workshopCity,
    required String latitude,
    required String longitude,
  }) {
    return repository.registerWorkshop(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      workshopName: workshopName,
      workshopNameAr: workshopNameAr,
      workshopAddress: workshopAddress,
      workshopCity: workshopCity,
      latitude: latitude,
      longitude: longitude,
    );
  }
}