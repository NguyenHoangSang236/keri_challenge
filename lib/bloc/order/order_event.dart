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
