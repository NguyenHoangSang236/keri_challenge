part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();
}

class OrderInitial extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderLoadingState extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderClearedState extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderListByReceiverNameLoadedState extends OrderState {
  final List<Order> orderList;

  const OrderListByReceiverNameLoadedState(this.orderList);

  @override
  List<Object> get props => [orderList];
}

class OrderListByPhoneNumberLoadedState extends OrderState {
  final List<Order> orderList;

  const OrderListByPhoneNumberLoadedState(this.orderList);

  @override
  List<Object> get props => [orderList];
}

class ClientHistoryOrderListLoadedState extends OrderState {
  final List<Order> orderList;
  final int page;

  const ClientHistoryOrderListLoadedState(this.orderList, this.page);

  @override
  List<Object> get props => [orderList, page];
}

class ShipperHistoryOrderListLoadedState extends OrderState {
  final List<Order> orderList;
  final int page;

  const ShipperHistoryOrderListLoadedState(this.orderList, this.page);

  @override
  List<Object> get props => [orderList, page];
}

class OrderAddedState extends OrderState {
  final String message;

  const OrderAddedState(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderUpdatedState extends OrderState {
  final String message;

  const OrderUpdatedState(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderErrorState extends OrderState {
  final String message;

  const OrderErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

class ShippingOrderLoadedState extends OrderState {
  final Order shippingOrder;

  const ShippingOrderLoadedState(this.shippingOrder);

  @override
  List<Object> get props => [shippingOrder];
}

class OrderForwardedState extends OrderState {
  final String message;

  const OrderForwardedState(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderAcceptedState extends OrderState {
  final String message;

  const OrderAcceptedState(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderRefusedState extends OrderState {
  final String message;

  const OrderRefusedState(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderFinishedShippingState extends OrderState {
  final String message;

  const OrderFinishedShippingState(this.message);

  @override
  List<Object?> get props => [message];
}
