import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:notesapp/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}


class AuthStateUninitialized extends AuthState{
  const AuthStateUninitialized();
}

class AuthStateRegistering extends AuthState{
  final Exception? exception;
  const AuthStateRegistering(this.exception);
}

//logged in state
class AuthStateLoggedIn extends AuthState{
  //after log in app only wants current user from us to support the logging in
  final AuthUser user;  
  const AuthStateLoggedIn(this.user);
}


class AuthStateNeesVerification extends AuthState{
  const AuthStateNeesVerification();
}


class AuthStateLoggedOut extends AuthState with EquatableMixin{
  final Exception? exception;
  final bool isLoading;
  const AuthStateLoggedOut({required this.exception, required this.isLoading});

  @override
  List<Object?> get props => [exception, isLoading];
}

