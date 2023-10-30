import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/data/enum/ship_status_enum.dart';

import '../../core/failure/failure.dart';
import '../../main.dart';
import '../../services/firebase_database_service.dart';
import '../entities/order.dart';
import '../enum/firestore_enum.dart';

class OrderRepository {
  Future<Either<Failure, List<Order>>> getOrderList({
    required int page,
    int limit = 20,
    required String senderPhoneNumber,
  }) async {
    try {
      final start = limit * (page - 1);

      final docRef = fireStore
          .collection('orders')
          .orderBy('id')
          .where('senderPhoneNumber', isEqualTo: senderPhoneNumber)
          .startAfter([start]).limit(limit * page);

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
        'Caught getting order list from firestore error: ${e.toString()} \n${stackTrace.toString()}',
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
          .collection('orders')
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
          .collection('orders')
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
          .collection('orders')
          .orderBy('id', descending: false)
          .where('shipperPhoneNumber', isEqualTo: shipperPhoneNumber)
          .where('status', isEqualTo: ShipStatusEnum.shipping.name)
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
        return const Left(ExceptionFailure('Không có dữ liêụ'));
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting shipping order error: ${e.toString()} \n${stackTrace.toString()}',
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
          result = 'Update order successfully';
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
}
