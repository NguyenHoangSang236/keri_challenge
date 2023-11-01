part of 'shipper_service_bloc.dart';

abstract class ShipperServiceState extends Equatable {
  const ShipperServiceState();
}

class ShipperServiceInitial extends ShipperServiceState {
  @override
  List<Object> get props => [];
}

class ShipperServiceLoadingState extends ShipperServiceState {
  @override
  List<Object> get props => [];
}

class ShipperServiceClearedState extends ShipperServiceState {
  @override
  List<Object> get props => [];
}

class ShipperServiceAddedState extends ShipperServiceState {
  final String message;

  const ShipperServiceAddedState(this.message);
  @override
  List<Object?> get props => [message];
}

class ShipperServiceErrorState extends ShipperServiceState {
  final String message;

  const ShipperServiceErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
