import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/core/extension/datetime_extension.dart';
import 'package:keri_challenge/data/entities/shipper_service.dart';
import 'package:keri_challenge/data/enum/shipper_service_enum.dart';

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
    ShipperService? latestService;

    try {
      final docRef = fireStore
          .collection(FireStoreCollectionEnum.shipperService.name)
          .orderBy('id')
          .where('shipperPhoneNumber', isEqualTo: service.shipperPhoneNumber)
          .limitToLast(1);

      await docRef.get().then(
        (querySnap) {
          if (querySnap.docs.isNotEmpty) {
            latestService =
                ShipperService.fromJson(querySnap.docs.first.data());

            newId = querySnap.docs.isNotEmpty
                ? (querySnap.docs.first.data()['id'] as int) + 1
                : 0;

            service.id = newId;
          } else {
            service.id = 1;
          }
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      if (latestService != null &&
          latestService!.endDate.isAfter(DateTime.now()) &&
          latestService!.beginDate.isBefore(DateTime.now())) {
        return const Left(
          ExceptionFailure(
            'Bạn đang còn gói dịch vụ đang sử dụng, xin hãy sử dụng hết hạn gói dịch để đăng ký gói mới',
          ),
        );
      } else {
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

        // await FirebaseDatabaseService.updateData(
        //   data: {
        //     'shipperServiceStartDate': service.beginDate,
        //     'shipperServiceEndDate': service.endDate,
        //   },
        //   collection: FireStoreCollectionEnum.users.name,
        //   document: service.shipperPhoneNumber,
        // );

        return Right(result);
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Caught adding shipper service error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<ShipperService>>> getShipperServiceList({
    required String shipperPhoneNumber,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      int latestId = 0;

      final ref = fireStore
          .collection(FireStoreCollectionEnum.shipperService.name)
          .orderBy('id')
          .where('shipperPhoneNumber', isEqualTo: shipperPhoneNumber)
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
          .collection(FireStoreCollectionEnum.shipperService.name)
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

      List<ShipperService> serviceList =
          mapList.map((json) => ShipperService.fromJson(json)).toList();

      return Right(serviceList);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting client history order list error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShipperService>> getCurrentShipperService({
    required String shipperPhoneNumber,
  }) async {
    ShipperService? latestService;

    try {
      final docRef = fireStore
          .collection(FireStoreCollectionEnum.shipperService.name)
          .orderBy('id')
          .where('shipperPhoneNumber', isEqualTo: shipperPhoneNumber)
          .limitToLast(1);

      await docRef.get().then(
        (querySnap) {
          if (querySnap.docs.isNotEmpty) {
            latestService =
                ShipperService.fromJson(querySnap.docs.first.data());
          }
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      if (latestService == null) {
        return const Left(ApiFailure(
            'Bạn chưa đăng ký gói dịch vụ, hãy đăng kí để sử dụng gói dịch vụ của chúng tôi'));
      } else if (latestService!.endDate.isBefore(DateTime.now())) {
        return Left(
          ExceptionFailure(
            'Bạn vừa hết hạn gói dịch vụ gần đây nhất vào ngày ${latestService!.endDate.date}. Bạn cần đăng ký gói mới để sử dụng dịch vụ',
          ),
        );
      } else {
        return Right(latestService!);
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting current shipper service error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> checkExpireCurrentShipperService(
      String shipperPhoneNumber) async {
    ShipperService? latestService;

    try {
      final docRef = fireStore
          .collection(FireStoreCollectionEnum.shipperService.name)
          .orderBy('id')
          .where('shipperPhoneNumber', isEqualTo: shipperPhoneNumber)
          .limitToLast(1);

      await docRef.get().then(
        (querySnap) {
          if (querySnap.docs.isNotEmpty) {
            latestService =
                ShipperService.fromJson(querySnap.docs.first.data());
          }
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      if (latestService == null) {
        return const Left(
          ApiFailure(
            'Bạn chưa đăng ký gói dịch vụ, hãy đăng kí để sử dụng gói dịch vụ của chúng tôi',
          ),
        );
      } else if (latestService!.endDate.isBefore(DateTime.now())) {
        await FirebaseDatabaseService.updateData(
          data: {
            'status': ShipperServiceEnum.expired.name,
          },
          collection: FireStoreCollectionEnum.shipperService.name,
          document: latestService!.getShipperServiceDoc(),
        );

        return Right(
          'Bạn vừa hết hạn gói dịch vụ gần đây nhất vào ngày ${latestService!.endDate.date}. Bạn cần đăng ký gói mới để sử dụng dịch vụ',
        );
      } else {
        return Left(
          ApiFailure(
            'Bạn sẽ hết hạn gói dịch vụ vào ngày ${latestService!.endDate.date}.',
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting current shipper service error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }
}
