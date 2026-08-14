import 'package:car_care_plus/features/service_details/data/models/subservice_model.dart';
import 'package:car_care_plus/features/sub_services/data/repo/sub_service_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


abstract class SubServiceState {}
class SubServiceInitialState extends SubServiceState {}
class SubServiceLoadingState extends SubServiceState {}
class SubServiceSuccessState extends SubServiceState {
  final List<SubServiceModel> subServices;
  SubServiceSuccessState(this.subServices);
}
class SubServiceErrorState extends SubServiceState {
  final String message;
  SubServiceErrorState(this.message);
}

class SubServiceCubit extends Cubit<SubServiceState> {
  final SubServiceRepo _subServiceRepo;
  final List<SubServiceModel> selectedSubServices = []; // للخدمات التنافسية المحددة من العميل

  SubServiceCubit(this._subServiceRepo) : super(SubServiceInitialState());

  void fetchSubServices(int serviceId) async {
    emit(SubServiceLoadingState());
    try {
      final subServices = await _subServiceRepo.getSubServicesByServiceId(serviceId);
      emit(SubServiceSuccessState(subServices));
    } catch (error) {
      emit(SubServiceErrorState(error.toString()));
    }
  }

  void toggleSubServiceSelection(SubServiceModel subService) {
    if (selectedSubServices.contains(subService)) {
      selectedSubServices.remove(subService);
    } else {
      selectedSubServices.add(subService);
    }
  }
}