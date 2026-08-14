import 'package:dartz/dartz.dart';
import 'package:car_care_plus/features/auth/data/user_model.dart';

abstract class AuthRepository {
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  });

  Future<Either<String, UserModel>> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    bool isActive = true,
  });

  Future<Either<String, UserModel>> registerCompany({
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
    bool isActive = false,
  });

  Future<Either<String, String>> sendResetOtp({required String email});

  Future<Either<String, String>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });

  // 🆕 Profile Functions
  Future<Either<String, UserModel>> getProfile();

  Future<Either<String, UserModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? imagePath,
  });
}