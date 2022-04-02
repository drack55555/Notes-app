import 'package:notesapp/services/auth/auth_user.dart';
 

//ab es k and firebase_auth_provider k and auth_service k help se jitna mn utna Auth Provider add kr skte jo sb
// same System follow krega...
abstract class AuthProvider{
  Future<void> initialize();
  AuthUser? get currUser;
  Future<AuthUser> logIn({required String email, required String password});

  Future<AuthUser> createUser({required String email, required String password});

  Future<void> logOut();

  Future<void> sendEmailVerification();
}