import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keri_challenge/core/extension/latLng_extension.dart';
import 'package:keri_challenge/data/entities/user.dart';
import 'package:keri_challenge/data/enum/firestore_enum.dart';
import 'package:keri_challenge/data/repository/account_repository.dart';
import 'package:keri_challenge/services/firebase_message_service.dart';
import 'package:keri_challenge/services/local_storage_service.dart';
import 'package:keri_challenge/util/value_render.dart';

import '../../data/enum/local_storage_enum.dart';
import '../../services/firebase_database_service.dart';

part 'author_event.dart';
part 'author_state.dart';

class AuthorBloc extends Bloc<AuthorEvent, AuthorState> {
  final AccountRepository _accountRepository;
  User? currentUser;

  AuthorBloc(this._accountRepository) : super(AuthorInitial()) {
    on<OnLoginEvent>((event, emit) async {
      emit(AuthorLoadingState());

      try {
        final response = await _accountRepository.login(
          event.phoneNumber,
          event.password,
        );

        response.fold(
          (failure) => emit(AuthorErrorState(failure.message)),
          (user) {
            currentUser = user;
            ValueRender.currentUser = user;

            FirebaseMessageService.subscribeToTopic(user.phoneNumber);

            emit(AuthorLoggedInState(currentUser!));
          },
        );
      } catch (e, stackTrace) {
        debugPrint(
            'Caught login error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AuthorErrorState(e.toString()));
      }
    });

    on<OnUpdateCurrentLocationEvent>((event, emit) async {
      emit(AuthorLoadingState());

      try {
        final response = await _accountRepository.updateUser(
          {'currentLocation': event.currentLocationLatLng.toGeoPoint},
          currentUser!.phoneNumber,
        );

        response.fold(
          (failure) => emit(AuthorErrorState(failure.message)),
          (success) {
            currentUser?.currentLocation =
                event.currentLocationLatLng.toGeoPoint;

            ValueRender.currentUser?.currentLocation =
                event.currentLocationLatLng.toGeoPoint;

            emit(AuthorCurrentLocationUpdatedState(success));
          },
        );
      } catch (e, stackTrace) {
        debugPrint(
            'Caught logout error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AuthorErrorState(e.toString()));
      }
    });

    on<OnLogoutEvent>((event, emit) async {
      emit(AuthorLoadingState());

      try {
        final response = await _accountRepository.updateUser(
          {'isOnline': false},
          currentUser!.phoneNumber,
        );

        response.fold(
          (failure) => emit(AuthorErrorState(failure.message)),
          (success) {
            FirebaseMessageService.unsubscribeFromTopic(
              currentUser!.phoneNumber,
            );

            currentUser = null;

            ValueRender.currentUser = null;

            emit(AuthorLoggedOutState());
          },
        );
      } catch (e, stackTrace) {
        debugPrint(
            'Caught logout error: ${e.toString()} \n${stackTrace.toString()}');
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
