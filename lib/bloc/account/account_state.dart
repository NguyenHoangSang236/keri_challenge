part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
  const AccountState();
}

class AccountInitial extends AccountState {
  @override
  List<Object> get props => [];
}

class AccountLoadingState extends AccountState {
  @override
  List<Object> get props => [];
}

class AccountClearedState extends AccountState {
  @override
  List<Object> get props => [];
}

class ClientAccountListLoadedState extends AccountState {
  final List<User> userList;

  const ClientAccountListLoadedState(this.userList);

  @override
  List<Object> get props => [userList];
}

class ShipperAccountListLoadedState extends AccountState {
  final List<User> userList;

  const ShipperAccountListLoadedState(this.userList);

  @override
  List<Object> get props => [userList];
}

class AccountErrorState extends AccountState {
  final String message;

  const AccountErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
