part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class OnLoadUserListEvent extends AccountEvent {
  final String role;
  final int limit;

  const OnLoadUserListEvent(this.role, this.limit);
}

class OnClearAccountEvent extends AccountEvent {}
