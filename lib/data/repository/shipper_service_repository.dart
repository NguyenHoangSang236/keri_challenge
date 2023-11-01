import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/data/entities/shipper_service.dart';

import '../../core/failure/failure.dart';
import '../../main.dart';
import '../../services/firebase_database_service.dart';
import '../enum/firestore_enum.dart';

class ShipperServiceRepository {
  Future<Either<Failure, String>> registerNewShipperService(
    ShipperService service,
  ) async {
    String result = '';
    int newId = 0;

    final docRef = fireStore
        .collection('orders')
        .orderBy('id')
        .where('shipperPhoneNumber', isEqualTo: service.shipperPhoneNumber)
        .limitToLast(1);

    await docRef.get().then(
      (querySnap) {
        newId = querySnap.docs.isNotEmpty
            ? (querySnap.docs.first.data()['id'] as int)
            : 0;

        service.id = newId;
      },
      onError: (e) => debugPrint("Error getting document list: $e"),
    );

    try {
      await FirebaseDatabaseService.addData(
        data: service.toJson(),
        collection: FireStoreCollectionEnum.shipperService.name,
        document: service.getShipperServiceDoc(),
      ).then(
        (value) {
          result =
              'Đăng ký gói dịch vụ mới thành công, xin hãy đợi quản trị viên duyệt hoá đơn của bạn';
        },
      );

      return Right(result);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught adding shipper service error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }
}
