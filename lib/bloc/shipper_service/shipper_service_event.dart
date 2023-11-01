part of 'shipper_service_bloc.dart';

abstract class ShipperServiceEvent extends Equatable {
  ShipperServiceEvent();

  @override
  List<Object?> props = [];
}

class OnAddNewShipperService extends ShipperServiceEvent {
  final ShipperService newService;

  OnAddNewShipperService(this.newService);
}

class OnLoadHistoryShipperServiceList extends ShipperServiceEvent {
  final String shipperPhoneNumber;
  final int limit;
  final int page;

  OnLoadHistoryShipperServiceList(
    this.shipperPhoneNumber,
    this.limit,
    this.page,
  );
}
