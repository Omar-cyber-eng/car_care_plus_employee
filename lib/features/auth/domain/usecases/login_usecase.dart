import 'package:car_care_plus/features/auth/data/user_model.dart';
import '../repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String, UserModel>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}