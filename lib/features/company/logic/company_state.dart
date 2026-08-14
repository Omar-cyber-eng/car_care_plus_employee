import '../data/models/company_model.dart';

abstract class CompanyState {}

class CompanyInitialState extends CompanyState {}

// حالات جلب بيانات الشركة
class CompanyLoadingState extends CompanyState {}

class CompanySuccessState extends CompanyState {
  final CompanyModel company;
  CompanySuccessState(this.company);
}

class CompanyErrorState extends CompanyState {
  final String message;
  CompanyErrorState(this.message);
}

// حالات تعديل بيانات الشركة
class UpdateCompanyLoadingState extends CompanyState {}

class UpdateCompanySuccessState extends CompanyState {
  final CompanyModel company;
  UpdateCompanySuccessState(this.company);
}
