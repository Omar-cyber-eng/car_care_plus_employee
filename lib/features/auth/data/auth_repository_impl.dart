// lib/features/auth/data/auth_repository_impl.dart

import 'package:car_care_plus/core/helper/shared_pref_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:car_care_plus/features/auth/data/auth_remote_data_source.dart';
import 'package:car_care_plus/features/auth/data/user_model.dart';
import 'package:car_care_plus/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      if (user.token != null && user.token!.isNotEmpty) {
      await SharedPrefHelper.setSecuredString(SharedPrefKeys.userToken, user.token!);
    }

      return Right(user);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, UserModel>> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    bool isActive = true,
  }) async {
    try {
      final user = await remoteDataSource.registerCustomer(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        isActive: isActive,
      );
      return Right(user);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
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
  }) async {
    try {
      final user = await remoteDataSource.registerCompany(
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
        isActive: isActive,
      );
      return Right(user);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  
  @override
  Future<Either<String, String>> sendResetOtp({required String email}) async {
    try {
      final message = await remoteDataSource.sendResetOtp(email: email);
      return Right(message);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, String>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final message = await remoteDataSource.resetPasswordWithOtp(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return Right(message);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
Future<Either<String, UserModel>> getProfile() async {
  try {
    final user = await remoteDataSource.getProfile();
    return Right(user);
  } catch (e) {
    return Left(e.toString().replaceAll('Exception: ', ''));
  }
}

@override
Future<Either<String, UserModel>> updateProfile({
  String? name,
  String? email,
  String? phone,
  String? imagePath,
}) async {
  try {
    final user = await remoteDataSource.updateProfile(
      name: name,
      email: email,
      phone: phone,
      imagePath: imagePath,
    );
    return Right(user);
  } catch (e) {
    return Left(e.toString().replaceAll('Exception: ', ''));
  }
}

}
