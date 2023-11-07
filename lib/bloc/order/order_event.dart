part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  OrderEvent();

  @override
  List<Object?> props = [];
}

class OnLoadClientHistoryOrderList extends OrderEvent {
  final String senderPhoneNumber;
  final int limit;
  final int page;

  OnLoadClientHistoryOrderList(this.senderPhoneNumber, this.limit, this.page);
}

class OnLoadShipperHistoryOrderList extends OrderEvent {
  final String shipperPhoneNumber;
  final int limit;
  final int page;

  OnLoadShipperHistoryOrderList(this.shipperPhoneNumber, this.limit, this.page);
}

class OnLoadShippingOrderEvent extends OrderEvent {
  final String shipperPhoneNumber;

  OnLoadShippingOrderEvent(this.shipperPhoneNumber);
}

class OnAddNewOrderEvent extends OrderEvent {
  final Order newOrder;

  OnAddNewOrderEvent(this.newOrder);
}

class OnSearchOrderByReceiverNameEvent extends OrderEvent {
  final String receiverName;

  OnSearchOrderByReceiverNameEvent(this.receiverName);
}

class OnSearchOrderByPhoneNumberEvent extends OrderEvent {
  final String phoneNumber;

  OnSearchOrderByPhoneNumberEvent(this.phoneNumber);
}

class OnForwardOrderEvent extends OrderEvent {
  final String shipperPhoneNumber;

  OnForwardOrderEvent(this.shipperPhoneNumber);
}

class OnUpdateOrderEvent extends OrderEvent {
  final String doc;
  final Map<String, dynamic> data;

  OnUpdateOrderEvent(this.doc, this.data);
}

class OnAcceptOrderEvent extends OrderEvent {
  final String doc;
  final String shipperPhoneNumber;

  OnAcceptOrderEvent(this.doc, this.shipperPhoneNumber);
}

class OnRefuseOrderEvent extends OrderEvent {
  final String doc;
  final String shipperPhoneNumber;

  OnRefuseOrderEvent(this.doc, this.shipperPhoneNumber);
}

class OnGetCurrentNewOrderEvent extends OrderEvent {
  final Order order;

  OnGetCurrentNewOrderEvent(this.order);
}

class OnFinishShippingOrderEvent extends OrderEvent {
  final String doc;

  OnFinishShippingOrderEvent(this.doc);
}

class OnClearOrderEvent extends OrderEvent {}
