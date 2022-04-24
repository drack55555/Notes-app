
//This bloc is everything required for Authentication... 

import 'package:bloc/bloc.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider provider) :  super(const AuthStateLoading ()){
    //emit allows us to emit and send states from auth bloc out to whoever is watching the state change
    on<AuthEventInitialize>((event, emit)async {
      await provider.initialize();
      final user= provider.currUser;
      if(user == null){
        emit(const AuthStateLoggedOut());
      }
      else if(!user.isEmailVerified){
        emit(const AuthStateNeesVerification());
      }
      else{
        emit(AuthStateLoggedIn(user));
      }
    });

    //Log In
    on<AutheEventLogIn>((event, emit) async{
      emit(const AuthStateLoading());
      final email=  event.email;
      final password= event.password;
      try {
        final user=await provider.logIn(email: email, password: password);
        emit(AuthStateLoggedIn(user));
      }
      on Exception catch (e){
        emit(AuthStateLogInFailure(e));
      }
    });

    //log out
    on<AuthEventLogOut>((event, emit) async{
      try {  //on a LogOut event..
        emit(const AuthStateLoading());// first go to the loading state..
        await provider.logOut(); // and then if it could log the user out..
        emit(const AuthStateLoggedOut()); //then it actually says that I'm logged out... and to Main fun..Logged out event is send..now go to main file to understand..
      } on Exception catch (e) {
        emit(AuthStateLogOutFailure(e));
      } 
    });
  }
}