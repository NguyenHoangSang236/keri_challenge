import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/data/entities/user.dart';
import 'package:keri_challenge/data/enum/firestore_enum.dart';
import 'package:keri_challenge/services/local_storage_service.dart';

import '../../data/enum/local_storage_enum.dart';
import '../../services/firebase_database_service.dart';

part 'author_event.dart';
part 'author_state.dart';

class AuthorBloc extends Bloc<AuthorEvent, AuthorState> {
  User? currentUser;

  AuthorBloc() : super(AuthorInitial()) {
    on<OnLoginEvent>((event, emit) async {
      emit(AuthorLoadingState());

      try {
        await FirebaseDatabaseService.getObjectMap(
          collection: FireStoreCollectionEnum.users.name,
          document: event.phoneNumber,
        ).then((responseMap) async {
          if (responseMap != null) {
            if (responseMap['password'] != event.password) {
              emit(const AuthorErrorState('Sai mật khẩu'));
            }

            String fcmToken = await LocalStorageService.getLocalStorageData(
              LocalStorageEnum.phoneToken.name,
            ) as String;

            await FirebaseDatabaseService.updateData(
              data: {'phoneFcmToken': fcmToken},
              collection: FireStoreCollectionEnum.users.name,
              document: event.phoneNumber,
            );

            emit(AuthorLoggedInState(User.fromJson(responseMap)));
          } else {
            emit(const AuthorErrorState('Tài khoản này không tồn tại'));
          }
        });
      } catch (e, stackTrace) {
        debugPrint(
            'Caught login error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AuthorErrorState(e.toString()));
      }
    });

    on<OnRegisterEvent>((event, emit) async {
      emit(AuthorLoadingState());

      try {
        final responseMap = await FirebaseDatabaseService.getObjectMap(
          collection: FireStoreCollectionEnum.users.name,
          document: event.newUser.phoneNumber,
        );

        if (responseMap == null) {
          Map<String, dynamic> userMap = event.newUser.toJson();

          String fcmToken = await LocalStorageService.getLocalStorageData(
            LocalStorageEnum.phoneToken.name,
          ) as String;

          await FirebaseDatabaseService.addData(
            data: userMap,
            collection: FireStoreCollectionEnum.users.name,
            document: event.newUser.phoneNumber,
          );

          emit(const AuthorRegisteredState('Đăng ký tài khoản mới thành công'));
        } else {
          emit(const AuthorErrorState('Tài khoản này đã tồn tại'));
        }
      } catch (e, stackTrace) {
        debugPrint(
            'Caught register error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AuthorErrorState(e.toString()));
      }
    });
  }
}
