part of 'author_bloc.dart';

abstract class AuthorState extends Equatable {
  const AuthorState();
}

class AuthorInitial extends AuthorState {
  @override
  List<Object> get props => [];
}

class AuthorLoadingState extends AuthorState {
  @override
  List<Object?> get props => [];
}

class AuthorLoggedInState extends AuthorState {
  final User user;

  const AuthorLoggedInState(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthorLoggedOutState extends AuthorState {
  @override
  List<Object?> get props => [];
}

class AuthorRegisteredState extends AuthorState {
  final String message;

  const AuthorRegisteredState(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthorCurrentLocationUpdatedState extends AuthorState {
  final String message;

  const AuthorCurrentLocationUpdatedState(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthorErrorState extends AuthorState {
  final String message;

  const AuthorErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
