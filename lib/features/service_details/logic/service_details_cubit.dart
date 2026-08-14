import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/service_details_repo.dart';
import 'service_details_state.dart';

class ServiceDetailsCubit extends Cubit<ServiceDetailsState> {
  final ServiceDetailsRepo _repo;

  ServiceDetailsCubit(this._repo) : super(ServiceDetailsInitialState());

  Future<void> getServiceDetails(int serviceId) async {
    emit(ServiceDetailsLoadingState());
    try {
      final details = await _repo.getServiceDetails(serviceId);
      emit(ServiceDetailsSuccessState(details));
    } catch (e) {
      print('Service Details Error: $e');
      emit(ServiceDetailsErrorState('حدث خطأ أثناء جلب تفاصيل الخدمة'));
    }
  }
}