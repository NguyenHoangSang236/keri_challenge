import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/core/failure/failure.dart';
import 'package:keri_challenge/data/entities/app_config.dart';

import '../../main.dart';

class AppConfigRepository {
  Future<Either<Failure, AppConfig>> getAppConfig() async {
    try {
      final docRef = fireStore.collection('config').doc('appConfig');

      AppConfig? appConfig;

      await docRef.get().then(
        (docSnap) {
          if (docSnap.data() != null) {
            appConfig = AppConfig.fromJson(docSnap.data()!);
          }
        },
        onError: (e) {
          debugPrint("Error getting document list: $e");
          return Left(ApiFailure(e.toString()));
        },
      );

      if (appConfig != null) {
        return Right(appConfig!);
      } else {
        return const Left(ApiFailure('Data does not exist'));
      }

      return const Left(ApiFailure('Network issues'));
    } catch (e, stackTrace) {
      debugPrint(
        'Caught getting app config error: ${e.toString()} \n${stackTrace.toString()}',
      );
      return Left(ExceptionFailure(e.toString()));
    }
  }
}
