import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/core/extension/string%20_extension.dart';
import 'package:keri_challenge/entities/user.dart';
import 'package:keri_challenge/services/local_storage_service.dart';

import '../../services/firebase_database_service.dart';

part 'author_event.dart';
part 'author_state.dart';

class AuthorBloc extends Bloc<AuthorEvent, AuthorState> {
  User? currentUser;

  AuthorBloc() : super(AuthorInitial()) {
    on<OnLoginEvent>((event, emit) async {
      emit(AuthorLoadingState());

      try {
        final String response =
            await FirebaseDatabaseService.get('users/${event.userName}');

        if (!response.contains('No data available')) {
          String jsonString = response.substring(response.indexOf('{'));

          Map<String, dynamic> jsonMap = json.decode(jsonString.formatToJson);

          currentUser = User.fromJson(jsonMap);

          if (currentUser != null) {
            if (event.password == currentUser?.password) {
              currentUser?.fcmToken =
                  await LocalStorageService.getLocalStorageData('phoneToken')
                      as String;

              await FirebaseDatabaseService.set(
                currentUser,
                "/users/${currentUser!.name}",
              );

              emit(AuthorLoggedInState(currentUser!));
            } else {
              emit(const AuthorErrorState('Wrong password'));
            }
          } else {
            emit(AuthorErrorState(response));
          }
        } else {
          emit(const AuthorErrorState('This user is not existed'));
        }
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AuthorErrorState(e.toString()));
      }
    });

    on<OnRegisterEvent>((event, emit) async {
      emit(AuthorLoadingState());

      try {
        final String response =
            await FirebaseDatabaseService.get('users/${event.userName}');

        if (response.contains('No data available')) {
          User newUser = User(
            event.userName,
            event.password,
            event.phoneNumber,
            await LocalStorageService.getLocalStorageData('phoneToken')
                as String,
          );

          await FirebaseDatabaseService.set(
            newUser,
            "users/${newUser.name}",
          );

          emit(const AuthorRegisteredState('Register successfully'));
        } else {
          emit(const AuthorErrorState('This user has been existed'));
        }
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AuthorErrorState(e.toString()));
      }
    });
  }
}
