import 'package:dartz/dartz.dart';
import 'package:car_care_plus/features/auth/data/user_model.dart';

abstract class AuthRepository {
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  });

  // تسجيل الورشة 
  Future<Either<String, UserModel>> registerWorkshop({
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
  });

  Future<Either<String, String>> sendResetOtp({required String email});

  Future<Either<String, String>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<String, UserModel>> getProfile();

  Future<Either<String, UserModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? imagePath,
  });
}