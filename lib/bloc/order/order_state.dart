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

class OrderListLoadedState extends OrderState {
  final List<Order> orderList;
  final int page;

  const OrderListLoadedState(this.orderList, this.page);

  @override
  List<Object> get props => [orderList, page];
}

class OrderAddedState extends OrderState {
  final String message;

  const OrderAddedState(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderErrorState extends OrderState {
  final String message;

  const OrderErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
