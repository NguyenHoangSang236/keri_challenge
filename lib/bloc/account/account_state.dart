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

class AccountListByNameLoadedState extends AccountState {
  final List<User> userList;

  const AccountListByNameLoadedState(this.userList);

  @override
  List<Object> get props => [userList];
}

class AccountListByPhoneNumberLoadedState extends AccountState {
  final List<User> userList;

  const AccountListByPhoneNumberLoadedState(this.userList);

  @override
  List<Object> get props => [userList];
}

class AllAccountListByNameLoadedState extends AccountState {
  final List<User> userList;

  const AllAccountListByNameLoadedState(this.userList);

  @override
  List<Object> get props => [userList];
}

class PaginationAccountListLoadedState extends AccountState {
  final List<User> userList;
  final int page;

  const PaginationAccountListLoadedState(this.userList, this.page);

  @override
  List<Object> get props => [userList, page];
}

class AccountErrorState extends AccountState {
  final String message;

  const AccountErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
