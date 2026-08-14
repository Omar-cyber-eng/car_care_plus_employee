import '../data/models/service_details_model.dart';

abstract class ServiceDetailsState {}

class ServiceDetailsInitialState extends ServiceDetailsState {}

class ServiceDetailsLoadingState extends ServiceDetailsState {}

class ServiceDetailsSuccessState extends ServiceDetailsState {
  final ServiceDetailsModel serviceDetails;

  ServiceDetailsSuccessState(this.serviceDetails);
}

class ServiceDetailsErrorState extends ServiceDetailsState {
  final String message;

  ServiceDetailsErrorState(this.message);
}