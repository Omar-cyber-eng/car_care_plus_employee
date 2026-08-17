import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/features/auth/domain/repositories/auth_repository.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await authRepository.login(email: email, password: password);
    result.fold(
      (failureMessage) => emit(AuthFailure(failureMessage)),
      (userModel) => emit(AuthSuccess(userModel)),
    );
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(AuthInitial());
  }

  Future<void> registerWorkshop({
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
  }) async {
    emit(AuthLoading());
    final result = await authRepository.registerWorkshop(
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
    result.fold(
      (failureMessage) => emit(AuthFailure(failureMessage)),
      (userModel) => emit(AuthSuccess(userModel)),
    );
  }

  Future<void> sendResetOtp({required String email}) async {
    emit(AuthLoading());
    final result = await authRepository.sendResetOtp(email: email);
    result.fold(
      (failureMessage) => emit(AuthFailure(failureMessage)),
      (successMessage) => emit(SendOtpSuccess(successMessage)),
    );
  }

  Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(AuthLoading());
    final result = await authRepository.resetPasswordWithOtp(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    result.fold(
      (failureMessage) => emit(AuthFailure(failureMessage)),
      (successMessage) => emit(ResetPasswordSuccess(successMessage)),
    );
  }

  Future<void> fetchProfile() async {
    emit(AuthLoading());
    final result = await authRepository.getProfile();
    result.fold(
      (failureMessage) => emit(AuthFailure(failureMessage)),
      (userModel) => emit(AuthSuccess(userModel)),
    );
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? imagePath,
  }) async {
    emit(AuthLoading());
    final result = await authRepository.updateProfile(
      name: name,
      email: email,
      phone: phone,
      imagePath: imagePath,
    );
    result.fold(
      (failureMessage) => emit(AuthFailure(failureMessage)),
      (userModel) => emit(AuthSuccess(userModel)),
    );
  }
}
