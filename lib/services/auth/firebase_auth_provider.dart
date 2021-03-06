import 'package:firebase_core/firebase_core.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/services/auth/auth_user.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth/auth_exception.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;


//login button--->call-->auth service--->auth services logIn function--->talk with provider-->provider talk with firebase code--->which in turns talk with the firebase backend.
//this talking is called END to END...
class  FirebaseAuthProvider implements AuthProvider {

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    try {   //creation of user if everything goes fine...
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user= currUser;
      if(user != null){
        return user;
      }
      else{
        throw UserNotLoggedInAuthException();
      }
    }
    on FirebaseAuthException catch(e){
      if(e.code== 'weak-password'){
        throw WeakPasswordAuthException();
      }
      else if(e.code== 'email-already-in-use'){
        throw EmailAlreadyInUseAuthException();
      }
      else if(e.code=='invalid-email'){
        throw InvalidEmailAuthException();
      }
      else{
        throw GenericAuthException();
      }
    }
    catch(_){
      throw GenericAuthException();
    }
  }

  @override //gets current user from firebase/...
  AuthUser? get currUser {
    final user= FirebaseAuth.instance.currentUser;
    if(user != null){
      return AuthUser.fromFirebase(user);
    }
    else{
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user= currUser;
      if(user != null){
        return user;
      }
      else{
        throw UserNotLoggedInAuthException();
      }
    }
    on FirebaseAuthException catch(e){
        if(e.code=='user-not-found'){
          throw UserNotFoundAuthException();
        }
        else if(e.code=='wrong-password'){
          throw WrongPasswordAuthException();
        }
        else{
          throw GenericAuthException();
        }
    }
    catch (_){      //if not FirebaseAuthException then come to this 'CATCH' block..
      throw GenericAuthException();
    }                                          
  }

  @override
  Future<void> logOut() async {
    final user= FirebaseAuth.instance.currentUser;
    if(user!= null){
      await FirebaseAuth.instance.signOut();
    }
    else{
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async{
    final user= FirebaseAuth.instance.currentUser;
    if(user!= null){
      await user.sendEmailVerification();
    }
    else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(     //ye kra kuki firebase initialize sbse phle krna
          options: DefaultFirebaseOptions.currentPlatform,   //tha and us k baad he login/
    );
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } 
    on FirebaseAuthException catch(e){
      switch(e.code){
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthException();
      }
    } 
    catch (_) {
      throw GenericAuthException();
    }
  }

}