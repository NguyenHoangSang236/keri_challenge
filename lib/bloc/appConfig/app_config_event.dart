part of 'app_config_bloc.dart';

abstract class AppConfigEvent extends Equatable {
  const AppConfigEvent();

  @override
  List<Object?> get props => [];
}

class OnLoadAppConfigEvent extends AppConfigEvent {}

class OnUpdateAppConfigEvent extends AppConfigEvent {
  final AppConfig appConfig;

  const OnUpdateAppConfigEvent(this.appConfig);
}
