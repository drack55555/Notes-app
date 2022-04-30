import 'dart:async';

import 'package:notesapp/services/auth/auth_exception.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider= MockAuthProvider();

    test('Should not be initialized to begin with',() {
      expect(provider.isInitialized,false);
    });

    test('Cannot log out if not initialized',  () {
      expect(provider.logOut(), throwsA(const TypeMatcher<NotInitializeException>()));
    });

    test('Should not be able to initialize',() async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization',() {
      expect(provider.currUser,null);
    });

    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized,true);
      }, 
      timeout: const  Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to Login', () async {

      final badEmailUser = provider.createUser(email: 'raj@gmail.com', password: 'anypassword');
      expect(badEmailUser,throwsA(const TypeMatcher<UserNotFoundAuthException>()));
  
      final badPasswordUser= provider.createUser(email: 'rajkr@gmail.com', password: 'raj');
      expect(badPasswordUser,throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(email: 'foo', password:'bar');
      expect(provider.currUser,user);

      expect(user.isEmailVerified,false);
    });

    test('Logged in user should be able to get verified',(){
      provider.sendEmailVerification();
      final user= provider.currUser;
      expect(user,isNotNull);
      expect(user!.isEmailVerified,true);
    });

    test('Should be able to log out and login again',() async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user= provider.currUser;
      expect(user,isNotNull);
    });

  });
}

class NotInitializeException implements Exception{}

class MockAuthProvider implements AuthProvider{
  AuthUser? _user;  //By default it's null...
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

//Mock implementation of Create User...Does 3 things: : 
      //Checks if user initialized and if not initialized throws an exception..
      //Does mock 1 second wait just a fake making a API call..
      //It calls Login fun with same email and password and returns the result of Login just so
      //...we can get the Auth User...
  @override 
  Future<AuthUser> createUser({required String email, required String password}) async {
    if(!isInitialized) throw NotInitializeException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  
  AuthUser? get currUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized= true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if(!isInitialized) throw NotInitializeException();
    if(email == 'raj@gmail.com') throw UserNotFoundAuthException();
    if(password == 'raj') throw WrongPasswordAuthException();
    const user= AuthUser(id: 'my_id', isEmailVerified: false, email: 'foo@gmail.com');
    _user = user;
    return Future.value(user);
  }
  @override
  Future<void> logOut() async {
    if(!isInitialized) throw NotInitializeException();
    if(_user== null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user= null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if(!isInitialized) throw NotInitializeException();
    final user = _user;
    if(user==null) throw UserNotFoundAuthException();
    const newUser= AuthUser(id: 'my_id', isEmailVerified: true, email: 'foo@gmail.com');
    _user= newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    
    throw UnimplementedError();
  }

}