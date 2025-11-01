part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}


final class AuthInitialState extends AuthState {}

final class AuthLoadingState extends AuthState {}
final class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object> get props => [message];
}

final class AuthLoggedInState extends AuthState {}

final class AuthLoggedOutState extends AuthState {}




