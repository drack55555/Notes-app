import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent{
  const AuthEvent();
}
class AuthEventInitialize extends AuthEvent{
  const AuthEventInitialize();
}

class AuthEventSendEmailVerification extends AuthEvent{ //send email verification to new currently logged in user..
  const AuthEventSendEmailVerification();
}


class AutheEventLogIn extends AuthEvent{
  final String email;
  final String password;

  const AutheEventLogIn(this.email, this.password);
}

class AuthEventRegister extends AuthEvent{
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventShouldRegister extends AuthEvent{
  const AuthEventShouldRegister();
}


class AuthEventForgotPassword extends AuthEvent{
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventLogOut extends AuthEvent{
  const AuthEventLogOut();
}

