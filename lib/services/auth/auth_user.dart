
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';


//This copies Firebase user to our own Auth User so we are not exposing Firebase's user and all
//it's properties to our user interface...
@immutable
class AuthUser{
  final String id; //so that we can store contents of every user in database using their Ids..
  final String? email;
  final bool isEmailVerified;
  const AuthUser({required this.id, required this.email, required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(id: user.uid, email:user.email!, isEmailVerified: user.emailVerified);
  }
 
}