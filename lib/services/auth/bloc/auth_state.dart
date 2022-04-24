

import 'package:flutter/foundation.dart';
import 'package:notesapp/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}


//loading state
class AuthStateLoading extends AuthState{
  const AuthStateLoading();
}

//logged in state
class AuthStateLoggedIn extends AuthState{
  //after log in app only wants current user from us to support the logging in
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}


class AuthStateLogInFailure extends AuthState{
  final Exception exception;
  const   AuthStateLogInFailure(this.exception);
}


class AuthStateNeesVerification extends AuthState{
  const AuthStateNeesVerification();
}


class AuthStateLoggedOut extends AuthState{
  const AuthStateLoggedOut();
}


class AuthStateLogOutFailure extends AuthState{
  final Exception exception;
  const   AuthStateLogOutFailure(this.exception);
}


