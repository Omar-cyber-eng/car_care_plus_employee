import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/company_model.dart';
import '../data/repos/company_repo.dart';
import 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepo _companyRepo;

  CompanyCubit(this._companyRepo) : super(CompanyInitialState());

  CompanyModel? company;

  /// جلب بيانات شركة المستخدم الحالي
  Future<void> getMyCompany() async {
    emit(CompanyLoadingState());
    try {
      company = await _companyRepo.getMyCompany();
      emit(CompanySuccessState(company!));
    } catch (error) {
      emit(CompanyErrorState(error.toString()));
    }
  }

  /// تعديل بيانات الشركة
  Future<void> updateCompany({
    required int companyId,
    required Map<String, dynamic> companyData,
  }) async {
    emit(UpdateCompanyLoadingState());
    try {
      company = await _companyRepo.updateCompany(
        companyId: companyId,
        companyData: companyData,
      );
      emit(UpdateCompanySuccessState(company!));
      // إعادة إرسال حالة النجاح لإعادة بناء الواجهة بالبيانات المحدّثة
      emit(CompanySuccessState(company!));
    } catch (error) {
      emit(CompanyErrorState(error.toString()));
    }
  }
}
