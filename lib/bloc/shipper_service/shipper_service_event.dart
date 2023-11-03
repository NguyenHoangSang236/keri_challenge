part of 'shipper_service_bloc.dart';

abstract class ShipperServiceEvent extends Equatable {
  ShipperServiceEvent();

  @override
  List<Object?> props = [];
}

class OnAddNewShipperServiceEvent extends ShipperServiceEvent {
  final ShipperService newService;

  OnAddNewShipperServiceEvent(this.newService);
}

class OnLoadCurrentShipperServiceEvent extends ShipperServiceEvent {
  final String shipperPhoneNumber;

  OnLoadCurrentShipperServiceEvent(this.shipperPhoneNumber);
}

class OnCheckExpiredCurrentShipperServiceEvent extends ShipperServiceEvent {
  final String shipperPhoneNumber;

  OnCheckExpiredCurrentShipperServiceEvent(this.shipperPhoneNumber);
}

class OnLoadHistoryShipperServiceListEvent extends ShipperServiceEvent {
  final String shipperPhoneNumber;
  final int limit;
  final int page;

  OnLoadHistoryShipperServiceListEvent(
    this.shipperPhoneNumber,
    this.limit,
    this.page,
  );
}

class OnClearShipperServiceEvent extends ShipperServiceEvent {}
