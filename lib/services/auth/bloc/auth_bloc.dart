
//This bloc is everything required for Authentication... 

import 'package:bloc/bloc.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider provider) :  super(const AuthStateUninitialized(isLoading: true)){ //absolutely initial state of the app should be in the loading state...so true.
    //send email verification..
    on<AuthEventSendEmailVerification> ((event, emit)async{
      await provider.sendEmailVerification();
      emit(state);
    } );
    on<AuthEventRegister>((event, emit) async{
      final email= event.email;
      final password= event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeesVerification(isLoading: false));
      }on Exception catch (e) {
        emit (AuthStateRegistering(exception: e, isLoading: false));
      }
    });


    //emit allows us to emit and send states from auth bloc out to whoever is watching the state change
    on<AuthEventInitialize>((event, emit)async {
      await provider.initialize();
      final user= provider.currUser;
      if(user == null){
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      }
      else if(!user.isEmailVerified){
        emit(const AuthStateNeesVerification(isLoading: false));
      }
      else{
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    }); 

    //Log In
    on<AutheEventLogIn>((event, emit) async{
      emit(const AuthStateLoggedOut(exception: null, isLoading: true));
      final email=  event.email;
      final password= event.password;
      try {
        final user=await provider.logIn(email: email, password: password);
        
        if(!user.isEmailVerified){ //email not verified..
          emit(const AuthStateLoggedOut(exception: null, isLoading: false, loadingText: 'Please wait while I log you in...'));
          emit(const AuthStateNeesVerification(isLoading: false));
        }

        else{
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(user:user, isLoading: false));
        }
      }
      on Exception catch (e){
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    //log out
    on<AuthEventLogOut>((event, emit) async{
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      }
      on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}