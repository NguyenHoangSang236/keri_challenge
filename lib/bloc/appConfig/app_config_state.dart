part of 'app_config_bloc.dart';

abstract class AppConfigState extends Equatable {
  const AppConfigState();
}

class AppConfigInitial extends AppConfigState {
  @override
  List<Object> get props => [];
}

class AppConfigLoadingState extends AppConfigState {
  @override
  List<Object> get props => [];
}

class AppConfigLoadState extends AppConfigState {
  final AppConfig appConfig;

  const AppConfigLoadState(this.appConfig);

  @override
  List<Object> get props => [appConfig];
}

class AppConfigUpdatedState extends AppConfigState {
  final String message;

  const AppConfigUpdatedState(this.message);
  @override
  List<Object?> get props => [message];
}

class AppConfigErrorState extends AppConfigState {
  final String message;

  const AppConfigErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
