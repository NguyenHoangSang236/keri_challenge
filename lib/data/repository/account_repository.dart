import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';

import '../../core/failure/failure.dart';
import '../../main.dart';
import '../../services/firebase_database_service.dart';
import '../../services/local_storage_service.dart';
import '../entities/user.dart';
import '../enum/firestore_enum.dart';
import '../enum/local_storage_enum.dart';

class AccountRepository {
  Future<Either<Failure, User>> login(
    String phoneNumber,
    String password,
  ) async {
    try {
      User? user;

      await FirebaseDatabaseService.getObjectMap(
        collection: FireStoreCollectionEnum.users.name,
        document: phoneNumber,
      ).then((responseMap) async {
        if (responseMap != null) {
          if (responseMap['password'] != password) {
            return const Left(ApiFailure('Sai mật khẩu'));
          }

          String fcmToken = await LocalStorageService.getLocalStorageData(
            LocalStorageEnum.phoneToken.name,
          ) as String;

          await FirebaseDatabaseService.updateData(
            data: {
              'phoneFcmToken': fcmToken,
              'isOnline': true,
            },
            collection: FireStoreCollectionEnum.users.name,
            document: phoneNumber,
          );

          user = User.fromJson(responseMap);
        }
      });

      if (user != null) {
        String? rememberPass = await LocalStorageService.getLocalStorageData(
            LocalStorageEnum.rememberLogin.name) as String?;

        if (rememberPass != null && rememberPass == 'true') {
          LocalStorageService.setLocalStorageData(
            LocalStorageEnum.phoneNumber.name,
            user!.phoneNumber,
          );
          LocalStorageService.setLocalStorageData(
            LocalStorageEnum.password.name,
            user!.password,
          );
        }

        return Right(user!);
      } else {
        return const Left(ApiFailure('Tài khoản này không tồn tại'));
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Caught login error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> updateUser(
    Map<String, dynamic> data,
    String phoneNumber,
  ) async {
    String result = '';

    try {
      await FirebaseDatabaseService.updateData(
        data: data,
        collection: FireStoreCollectionEnum.users.name,
        document: phoneNumber,
      ).then((value) => result = 'Update user successfully');

      return Right(result);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught login error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<User>>> getUserList({
    required String role,
    int limit = 10,
  }) async {
    List<User> userList = [];
    List<Map<String, dynamic>> mapList = [];

    try {
      final ref = fireStore
          .collection(FireStoreCollectionEnum.users.name)
          .orderBy('registerDate', descending: true)
          .where('role', isEqualTo: role)
          .limit(limit);

      await ref.get().then(
        (querySnap) {
          for (var docSnapshot in querySnap.docs) {
            mapList.add(docSnapshot.data());
          }
        },
        onError: (e) => debugPrint("Error getting document list: $e"),
      );

      userList = mapList.map((json) => User.fromJson(json)).toList();

      return Right(userList);
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting client history order list error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }
}
