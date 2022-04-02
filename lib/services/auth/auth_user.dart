
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';


//This copies Firebase user to our own Auth User so we are not exposing Firebase's user and all
//it's properties to our user interface...
@immutable
class AuthUser{
  final bool isEmailVerified;
  const AuthUser({required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(isEmailVerified: user.emailVerified);
  }
 
}