part of 'author_bloc.dart';

abstract class AuthorEvent extends Equatable {
  const AuthorEvent();

  @override
  List<Object?> get props => [];
}

class OnSaveVerificationIdEvent extends AuthorEvent {
  final String verificationId;

  const OnSaveVerificationIdEvent(this.verificationId);
}

class OnLoginEvent extends AuthorEvent {
  final String userName;
  final String password;

  const OnLoginEvent(this.userName, this.password);
}

class OnRegisterEvent extends AuthorEvent {
  final String userName;
  final String password;
  final String phoneNumber;

  const OnRegisterEvent(this.userName, this.password, this.phoneNumber);
}
