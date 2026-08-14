// lib/features/auth/domain/usecases/reset_password_with_otp_usecase.dart

import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordWithOtpUseCase {
  final AuthRepository repository;

  ResetPasswordWithOtpUseCase(this.repository);

  Future<Either<String, String>> call({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) {
    return repository.resetPasswordWithOtp(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}