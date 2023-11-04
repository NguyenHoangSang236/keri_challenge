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

class CurrentShipperServiceLoadedState extends ShipperServiceState {
  final ShipperService shipperService;

  const CurrentShipperServiceLoadedState(this.shipperService);

  @override
  List<Object> get props => [];
}

class ShipperServiceClearedState extends ShipperServiceState {
  @override
  List<Object> get props => [];
}

class ShipperServiceListLoadedState extends ShipperServiceState {
  final List<ShipperService> shipperServiceList;

  const ShipperServiceListLoadedState(this.shipperServiceList);
  @override
  List<Object?> get props => [shipperServiceList];
}

class ShipperServiceAddedState extends ShipperServiceState {
  final String message;

  const ShipperServiceAddedState(this.message);
  @override
  List<Object?> get props => [message];
}

class ShipperServiceExpiredState extends ShipperServiceState {
  final String message;

  const ShipperServiceExpiredState(this.message);
  @override
  List<Object?> get props => [message];
}

class ShipperServiceUnexpiredState extends ShipperServiceState {
  final String message;

  const ShipperServiceUnexpiredState(this.message);
  @override
  List<Object?> get props => [message];
}

class ShipperServiceAcceptedState extends ShipperServiceState {
  final String message;

  const ShipperServiceAcceptedState(this.message);
  @override
  List<Object?> get props => [message];
}

class ShipperServiceRejectedState extends ShipperServiceState {
  final String message;

  const ShipperServiceRejectedState(this.message);
  @override
  List<Object?> get props => [message];
}

class ShipperServiceErrorState extends ShipperServiceState {
  final String message;

  const ShipperServiceErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
