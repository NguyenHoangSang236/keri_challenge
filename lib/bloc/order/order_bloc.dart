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
  Order? currentNewOrder;
  Order? currentShippingOrder;
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
            (success) {
              currentNewOrder = event.newOrder;

              emit(OrderAddedState(success));
            },
          );
        } else {
          emit(const OrderErrorState('Add new order failed'));
        }
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(OrderErrorState(e.toString()));
      }
    });

    on<OnForwardOrderEvent>((event, emit) async {
      try {
        final response = await _orderRepository.updateOrder(
          {'shipperPhoneNumber': event.shipperPhoneNumber},
          currentNewOrder!.getOrderDoc(),
        );

        response.fold(
          (failure) => emit(OrderErrorState(failure.message)),
          (success) => emit(
            const OrderForwardedState('Chuyển đơn hàng thành công'),
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(OrderErrorState(e.toString()));
      }
    });

    on<OnUpdateOrderEvent>((event, emit) async {
      emit(OrderLoadingState());

      try {
        final response =
            await _orderRepository.updateOrder(event.data, event.doc);

        response.fold(
          (failure) => emit(OrderErrorState(failure.message)),
          (success) => emit(OrderUpdatedState(success)),
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(OrderErrorState(e.toString()));
      }
    });

    on<OnLoadShippingOrderEvent>((event, emit) async {
      emit(OrderLoadingState());

      try {
        final response =
            await _orderRepository.getShippingOrder(event.shipperPhoneNumber);

        response.fold(
          (failure) => emit(OrderErrorState(failure.message)),
          (order) {
            currentShippingOrder = order;

            emit(ShippingOrderLoadedState(order));
          },
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(OrderErrorState(e.toString()));
      }
    });

    on<OnClearOrderEvent>((event, emit) {
      currentPage = 1;
      currentNewOrder = null;
      currentShippingOrder = null;
      currentOrderList.clear();
    });
  }
}
