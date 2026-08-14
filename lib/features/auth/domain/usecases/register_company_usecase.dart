import 'package:car_care_plus/features/auth/data/user_model.dart';
import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class RegisterCompanyUseCase {
  final AuthRepository repository;

  RegisterCompanyUseCase(this.repository);

  Future<Either<String, UserModel>> call({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String companyName,
    required String companyNameAr,
    required String commercialReg,
    required String taxNumber,
    required String companyAddress,
  }) {
    return repository.registerCompany(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      companyName: companyName,
      companyNameAr: companyNameAr,
      commercialReg: commercialReg,
      taxNumber: taxNumber,
      companyAddress: companyAddress,
    );
  }
}
