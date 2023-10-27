import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';

import '../../core/failure/failure.dart';
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
}
