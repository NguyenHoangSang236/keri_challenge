import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/data/enum/shipper_enum.dart';

import '../../data/entities/order.dart';
import '../../data/repository/order_repository.dart';
import '../../services/firebase_message_service.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  int currentPage = 1;
  Order? currentNewOrder;
  Order? currentShippingOrder;
  List<Order> currentOrderList = [];

  OrderBloc(this._orderRepository) : super(OrderInitial()) {
    on<OnLoadClientHistoryOrderList>((event, emit) async {
      emit(OrderLoadingState());

      try {
        final response =
            await _orderRepository.getDescendingClientHistoryOrderList(
          page: event.page,
          limit: event.limit,
          senderPhoneNumber: event.senderPhoneNumber,
        );

        response.fold((failure) => emit(OrderErrorState(failure.message)),
            (list) {
          currentPage = event.page;
          currentOrderList = List.of(list);

          emit(ClientHistoryOrderListLoadedState(list, event.page));
        });
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(OrderErrorState(e.toString()));
      }
    });

    on<OnLoadShipperHistoryOrderList>((event, emit) async {
      emit(OrderLoadingState());

      try {
        final response =
            await _orderRepository.getDescendingShipperHistoryOrderList(
          page: event.page,
          limit: event.limit,
          shipperPhoneNumber: event.shipperPhoneNumber,
        );

        response.fold((failure) => emit(OrderErrorState(failure.message)),
            (list) {
          currentPage = event.page;
          currentOrderList = List.of(list);

          emit(ClientHistoryOrderListLoadedState(list, event.page));
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
      emit(OrderLoadingState());

      try {
        final response = await _orderRepository.updateOrder(
          {'shipperPhoneNumber': event.shipperPhoneNumber},
          currentNewOrder!.getOrderDoc(),
        );

        response.fold(
          (failure) => emit(OrderErrorState(failure.message)),
          (success) {
            FirebaseMessageService.sendMessage(
              title: 'Thông báo đơn hàng',
              content: 'Bạn có một đơn hàng mới',
              topic: event.shipperPhoneNumber,
            );

            currentNewOrder = null;

            emit(
              const OrderForwardedState('Chuyển đơn hàng thành công'),
            );
          },
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

    on<OnGetCurrentNewOrderEvent>((event, emit) {
      currentNewOrder = event.order;
    });

    on<OnAcceptOrderEvent>((event, emit) async {
      emit(OrderLoadingState());

      if (currentShippingOrder == null) {
        try {
          final response = await _orderRepository.actionsOnOrder(
            event.doc,
            event.shipperPhoneNumber,
            ShipperEnum.acceptOrder,
          );

          response.fold(
            (failure) => emit(OrderErrorState(failure.message)),
            (success) {
              FirebaseMessageService.sendMessage(
                title: 'Thông báo đơn hàng',
                content: 'Shipper đã nhận đơn hàng',
                topic: event.doc.substring(0, event.doc.indexOf('-')),
              );

              emit(const OrderAcceptedState('Đã nhận đơn hàng'));
            },
          );
        } catch (e, stackTrace) {
          debugPrint(
              'Caught error: ${e.toString()} \n${stackTrace.toString()}');
          emit(OrderErrorState(e.toString()));
        }
      } else {
        emit(const OrderErrorState('Bạn không thể giao 2 đơn cùng 1 lúc'));
      }
    });

    on<OnRefuseOrderEvent>((event, emit) async {
      emit(OrderLoadingState());

      try {
        final response = await _orderRepository.actionsOnOrder(
          event.doc,
          event.shipperPhoneNumber,
          ShipperEnum.refuseOrder,
        );

        response.fold(
          (failure) => emit(OrderErrorState(failure.message)),
          (success) async {
            FirebaseMessageService.sendMessage(
              title: 'Thông báo đơn hàng',
              content: 'Shipper đã từ chối đơn hàng',
              topic: event.doc.substring(0, event.doc.indexOf('-')),
            );

            emit(const OrderRefusedState('Đã từ chối đơn hàng'));
          },
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(OrderErrorState(e.toString()));
      }
    });

    on<OnFinishShippingOrderEvent>((event, emit) async {
      emit(OrderLoadingState());

      try {
        final response = await _orderRepository.finishShipping(
          {
            'shipDate': DateTime.now(),
            'status': ShipperEnum.shipped.name,
          },
          event.doc,
        );

        response.fold(
          (failure) => emit(OrderErrorState(failure.message)),
          (success) {
            FirebaseMessageService.sendMessage(
              title: 'Thông báo đơn hàng',
              content: 'Shipper đã hoàn thành đơn hàng',
              topic: currentShippingOrder!.senderPhoneNumber,
            );

            currentShippingOrder = null;

            emit(const OrderFinishedShippingState('Đã hoàn thành đơn hàng'));
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
