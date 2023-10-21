part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class OnSearchUserByNameEvent extends AccountEvent {
  final String userName;

  const OnSearchUserByNameEvent(this.userName);
}

class OnSearchUserByPhoneEvent extends AccountEvent {
  final String phoneNumber;

  const OnSearchUserByPhoneEvent(this.phoneNumber);
}

class OnLoadPaginationUserListEvent extends AccountEvent {
  final int page;

  const OnLoadPaginationUserListEvent(this.page);
}

class OnLoadAllUserListEvent extends AccountEvent {}

class OnClearFilterUserListEvent extends AccountEvent {}
