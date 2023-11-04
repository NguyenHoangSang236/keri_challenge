part of 'shipper_service_bloc.dart';

abstract class ShipperServiceEvent extends Equatable {
  ShipperServiceEvent();

  @override
  List<Object?> props = [];
}

class OnAddNewShipperServiceEvent extends ShipperServiceEvent {
  final ShipperService newService;
  final File billImageFile;

  OnAddNewShipperServiceEvent(this.newService, this.billImageFile);
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

class OnAcceptShipperServiceEvent extends ShipperServiceEvent {
  final ShipperService shipperService;

  OnAcceptShipperServiceEvent(this.shipperService);
}

class OnRejectShipperServiceEvent extends ShipperServiceEvent {
  final ShipperService shipperService;

  OnRejectShipperServiceEvent(this.shipperService);
}
