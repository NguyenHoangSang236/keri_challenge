import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/core/extension/datetime_extension.dart';
import 'package:keri_challenge/data/entities/shipper_service.dart';
import 'package:keri_challenge/data/enum/shipper_service_enum.dart';
import 'package:keri_challenge/services/firebase_storage_service.dart';

import '../../core/failure/failure.dart';
import '../../main.dart';
import '../../services/firebase_database_service.dart';
import '../enum/firestore_enum.dart';

class ShipperServiceRepository {
  Future<Either<Failure, String>> registerNewShipperService(
    ShipperService service,
    File billImage,
  ) async {
    String result = '';
    bool isSuccess = false;
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
        String billUrl = '';

        final fileRef =
            firebaseStorage.ref().child(service.getShipperServiceDoc());

        final UploadTask upLoadTask = fileRef.putFile(billImage);
        // upLoadTask.snapshotEvents.listen(
        //   (taskSnapshot) {
        //     switch (taskSnapshot.state) {
        //       case TaskState.running:
        //         final progress = 100.0 *
        //             (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
        //         debugPrint("Upload is $progress% complete.");
        //
        //         break;
        //       case TaskState.paused:
        //         debugPrint('Paused uploading file');
        //         break;
        //       case TaskState.success:
        //         debugPrint('Uploaded file successfully');
        //         break;
        //       case TaskState.canceled:
        //         debugPrint('Canceled uploading file');
        //         break;
        //       case TaskState.error:
        //         debugPrint('Caught error uploading file');
        //         break;
        //     }
        //   },
        // );

        await upLoadTask.whenComplete(() async {
          billUrl = await FirebaseStorageService.getFileUrl(
            service.getShipperServiceDoc(),
          );

          if (billUrl.isNotEmpty && billUrl != 'failed') {
            service.billImageUrl = billUrl;

            await FirebaseDatabaseService.addData(
              data: service.toJson(),
              collection: FireStoreCollectionEnum.shipperService.name,
              document: service.getShipperServiceDoc(),
            ).then((value) {
              isSuccess = true;
            });
          } else {
            isSuccess = false;
            result = 'Đăng ký thất bại, không thể tải hình ảnh lên';
          }
        });

        print('@@@');
        print(result);
        print(isSuccess);

        return isSuccess
            ? const Right(
                'Đăng ký gói dịch vụ mới thành công, xin hãy đợi quản trị viên duyệt hoá đơn của bạn',
              )
            : Left(ExceptionFailure(result));

        // FirebaseStorageService.uploadFile(
        //   billImage,
        //   service.getShipperServiceDoc(),
        //   onSuccess: (taskSnapshot)
        //   },
        //   // onError: (e) {
        //   //   debugPrint(e.toString());
        //   //   isSuccess = false;
        //   //   result = 'Đăng ký thất bại, không thể tải hình ảnh lên';
        //   // },
        // );
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

  Future<Either<Failure, String>> actionsOnShipperService(
    ShipperService shipperService,
    ShipperServiceEnum serviceEnum,
  ) async {
    try {
      FirebaseDatabaseService.updateData(
        data: {'status': serviceEnum.name},
        collection: FireStoreCollectionEnum.shipperService.name,
        document: shipperService.getShipperServiceDoc(),
      );

      if (serviceEnum == ShipperServiceEnum.accepted) {
        await FirebaseDatabaseService.updateData(
          data: {
            'shipperServiceStartDate': shipperService.beginDate,
            'shipperServiceEndDate': shipperService.endDate,
          },
          collection: FireStoreCollectionEnum.users.name,
          document: shipperService.shipperPhoneNumber,
        );
      }

      return const Right('Chỉnh sửa trạng thái đơn hàng thành công');
    } catch (e, stackTrace) {
      debugPrint(
        'Caught updating shipper service error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }
}
