import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/data/enum/shipper_enum.dart';
import 'package:keri_challenge/util/value_render.dart';

import '../../core/failure/failure.dart';
import '../../main.dart';
import '../../services/firebase_database_service.dart';
import '../entities/order.dart';
import '../enum/firestore_enum.dart';

class OrderRepository {
  Future<Either<Failure, List<Order>>> getDescendingClientHistoryOrderList({
    required int page,
    int limit = 20,
    required String senderPhoneNumber,
  }) async {
    try {
      int latestId = 0;

      final ref = fireStore
          .collection(FireStoreCollectionEnum.orders.name)
          .orderBy('id', descending: false)
          .where('senderPhoneNumber', isEqualTo: senderPhoneNumber)
          .limitToLast(1);

      await ref.get().then(
        (querySnap) {
          latestId = querySnap.docs.isNotEmpty
              ? (querySnap.docs.first.data()['id'] as int)
              : 0;
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      final int start = limit * (page - 1);

      final docRef = fireStore
          .collection(FireStoreCollectionEnum.orders.name)
          .orderBy('id', descending: true)
          .where('senderPhoneNumber', isEqualTo: senderPhoneNumber)
          .startAt([latestId - start]).limit(limit * page);

      List<Map<String, dynamic>> mapList = [];

      await docRef.get().then(
        (querySnap) {
          for (var docSnapshot in querySnap.docs) {
            mapList.add(docSnapshot.data());
          }
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      List<Order> orderList =
          mapList.map((json) => Order.fromJson(json)).toList();

      return Right(orderList);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting client history order list error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Order>>> getDescendingShipperHistoryOrderList({
    required int page,
    int limit = 20,
    required String shipperPhoneNumber,
  }) async {
    try {
      int latestId = 0;

      final ref = fireStore
          .collection(FireStoreCollectionEnum.orders.name)
          .orderBy('shipperOrderId', descending: true)
          .where('shipperPhoneNumber', isEqualTo: shipperPhoneNumber)
          .limit(1);

      await ref.get().then(
        (querySnap) {
          latestId = querySnap.docs.isNotEmpty
              ? (querySnap.docs.first.data()['id'] as int)
              : 0;
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      final int start = limit * (page - 1);

      final docRef = fireStore
          .collection(FireStoreCollectionEnum.orders.name)
          .orderBy('id', descending: true)
          .where('shipperPhoneNumber', isEqualTo: shipperPhoneNumber)
          .startAt([latestId - start]).limit(limit * page);

      List<Map<String, dynamic>> mapList = [];

      await docRef.get().then(
        (querySnap) {
          for (var docSnapshot in querySnap.docs) {
            mapList.add(docSnapshot.data());
          }
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      List<Order> orderList =
          mapList.map((json) => Order.fromJson(json)).toList();

      return Right(orderList);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting shipper history order list error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> getLatestOrderId(
    String senderPhoneNumber,
  ) async {
    try {
      int newId = 0;

      final docRef = fireStore
          .collection(FireStoreCollectionEnum.orders.name)
          .orderBy('id', descending: false)
          .where('senderPhoneNumber', isEqualTo: senderPhoneNumber)
          .limitToLast(1);

      await docRef.get().then(
        (querySnap) {
          newId = querySnap.docs.isNotEmpty
              ? (querySnap.docs.first.data()['id'] as int)
              : 0;
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      return Right(newId);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting latest order id from firestore error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> addNewOrder(Order newOrder) async {
    try {
      String result = 'Failed! ';

      await fireStore
          .collection(FireStoreCollectionEnum.orders.name)
          .doc('${newOrder.senderPhoneNumber}-${newOrder.id}')
          .set(newOrder.toJson())
          .then(
        (value) {
          result = 'Add new order successfully';
        },
      );

      return Right(result);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting order list from firestore error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, Order>> getShippingOrder(
    String shipperPhoneNumber,
  ) async {
    try {
      final docRef = fireStore
          .collection(FireStoreCollectionEnum.orders.name)
          .orderBy('id', descending: false)
          .where('shipperPhoneNumber', isEqualTo: shipperPhoneNumber)
          .where('status', isEqualTo: ShipperEnum.shipping.name)
          .limit(1);

      Order? shippingOrder;

      await docRef.get().then(
        (querySnap) {
          if (querySnap.docs.isNotEmpty) {
            shippingOrder = Order.fromJson(querySnap.docs.first.data());
          }
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      if (shippingOrder != null) {
        return Right(shippingOrder!);
      } else {
        return const Left(
          ExceptionFailure('Không có đơn hàng nào đang được giao'),
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting shipping order error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> actionsOnOrder(
    String orderId,
    String shipperPhoneNumber,
    ShipperEnum action,
  ) async {
    String result = '';
    Map<String, dynamic> data = {};
    int latestShipperOrderId = 0;

    if (action == ShipperEnum.acceptOrder) {
      data = {'status': ShipperEnum.shipping.name};

      final docRef = fireStore
          .collection(FireStoreCollectionEnum.orders.name)
          .orderBy('shipperOrderId', descending: true)
          .where('shipperPhoneNumber', isEqualTo: shipperPhoneNumber)
          .limit(1);

      await docRef.get().then(
        (querySnap) {
          if (querySnap.docs.isNotEmpty) {
            latestShipperOrderId = querySnap.docs.isNotEmpty
                ? (querySnap.docs.first.data()['id'] as int)
                : 0;

            data['shipperOrderId'] = latestShipperOrderId;
          }
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      await FirebaseDatabaseService.updateData(
        data: {'shipperWorkingStatus': ShipperEnum.unavailable.name},
        collection: FireStoreCollectionEnum.users.name,
        document: ValueRender.currentUser!.phoneNumber,
      );
    } else if (action == ShipperEnum.refuseOrder) {
      data = {
        'shipperPhoneNumber': null,
        'status': ShipperEnum.shipper_waiting.name,
        'shipperOrderId': null,
        'shipDate': null,
      };
    } else {
      return const Left(ExceptionFailure('Wrong action!'));
    }

    try {
      await FirebaseDatabaseService.updateData(
        data: data,
        collection: FireStoreCollectionEnum.orders.name,
        document: orderId,
      ).then(
        (value) {
          result = action == ShipperEnum.acceptOrder
              ? 'Đã nhận đơn hàng'
              : 'Đã từ chối đơn hàng';
        },
      );

      return Right(result);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught action on order error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> updateOrder(
    Map<String, dynamic> data,
    String orderId,
  ) async {
    String result = '';

    try {
      await FirebaseDatabaseService.updateData(
        data: data,
        collection: FireStoreCollectionEnum.orders.name,
        document: orderId,
      ).then(
        (value) {
          result = 'Chỉnh sửa đơn hàng thành công';
        },
      );

      return Right(result);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught updating order error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> finishShipping(
    Map<String, dynamic> data,
    String orderId,
  ) async {
    String result = '';

    try {
      await FirebaseDatabaseService.updateData(
        data: data,
        collection: FireStoreCollectionEnum.orders.name,
        document: orderId,
      ).then(
        (value) {
          result = 'Chỉnh sửa đơn hàng thành công';
        },
      );

      await FirebaseDatabaseService.updateData(
        data: {'shipperWorkingStatus': ShipperEnum.available.name},
        collection: FireStoreCollectionEnum.users.name,
        document: ValueRender.currentUser!.phoneNumber,
      );

      return Right(result);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught updating order error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }
}
