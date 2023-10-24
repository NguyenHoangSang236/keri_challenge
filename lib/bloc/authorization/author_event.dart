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
  final String phoneNumber;
  final String password;

  const OnLoginEvent(this.phoneNumber, this.password);
}

class OnRegisterEvent extends AuthorEvent {
  final User newUser;

  const OnRegisterEvent(this.newUser);
}
