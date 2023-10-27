import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/data/entities/app_config.dart';

import '../../data/repository/app_config_repository.dart';

part 'app_config_event.dart';
part 'app_config_state.dart';

class AppConfigBloc extends Bloc<AppConfigEvent, AppConfigState> {
  final AppConfigRepository _appConfigRepository;
  AppConfig? appConfig;

  AppConfigBloc(this._appConfigRepository) : super(AppConfigInitial()) {
    on<OnLoadAppConfigEvent>((event, emit) async {
      emit(AppConfigLoadingState());

      try {
        final response = await _appConfigRepository.getAppConfig();

        response.fold(
          (failure) => emit(AppConfigErrorState(failure.message)),
          (config) {
            appConfig = config;

            emit(AppConfigLoadState(config));
          },
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AppConfigErrorState(e.toString()));
      }
    });
  }
}
