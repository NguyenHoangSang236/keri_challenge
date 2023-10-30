part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  OrderEvent();

  @override
  List<Object?> props = [];
}

class OnLoadOrderListEvent extends OrderEvent {
  final String senderPhoneNumber;
  final int limit;
  final int page;

  OnLoadOrderListEvent(this.senderPhoneNumber, this.limit, this.page);
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

class OnClearOrderEvent extends OrderEvent {}
