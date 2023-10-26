import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../data/entities/order.dart';
import '../../data/repository/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  int currentPage = 1;
  List<Order> currentOrderList = [];

  OrderBloc(this._orderRepository) : super(OrderInitial()) {
    on<OnLoadOrderListEvent>((event, emit) async {
      emit(OrderLoadingState());

      try {
        final response = await _orderRepository.getOrderList(
          page: event.page,
          limit: event.limit,
          senderPhoneNumber: event.senderPhoneNumber,
        );

        response.fold((failure) => emit(OrderErrorState(failure.message)),
            (list) {
          currentPage = event.page;
          currentOrderList = List.of(list);

          emit(OrderListLoadedState(list, event.page));
        });
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(OrderErrorState(e.toString()));
      }
    });

    on<OnAddNewOrderEvent>((event, emit) async {
      emit(OrderLoadingState());

      try {
        int newId = 0;

        final response = await _orderRepository
            .getLatestOrderId(event.newOrder.senderPhoneNumber);

        response.fold(
          (failure) => emit(OrderErrorState(failure.message)),
          (id) => newId = id + 1,
        );

        if (newId > 0) {
          event.newOrder.id = newId;

          final res = await _orderRepository.addNewOrder(event.newOrder);

          res.fold(
            (failure) => emit(OrderErrorState(failure.message)),
            (success) => emit(OrderAddedState(success)),
          );
        } else {
          emit(const OrderErrorState('Add new order failed'));
        }
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(OrderErrorState(e.toString()));
      }
    });
  }
}
