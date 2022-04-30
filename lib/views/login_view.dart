import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth/auth_exception.dart';
import 'package:notesapp/services/auth/bloc/auth_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';
import 'package:notesapp/utilities/dialogs/error_dialog.dart';
import 'package:notesapp/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if(state is AuthStateLoggedOut){ // all the exceptions handling..

          if(state.exception is UserNotFoundAuthException){
            await showErrorDialog(context, 'User not found');
          }
          else if(state.exception is WrongPasswordAuthException){
            await showErrorDialog(context, 'Wrong Credentials!');
          }
          else if(state.exception is GenericAuthException){
            await showErrorDialog(context, 'Authentication Error!');
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(title: const Text('Login Here!')),
          body: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              children: [
                const Text('Please log into your account in order to interact with and create notes!'),
                TextField(
                  controller: _email,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your Email',
                  ),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter your password here',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    
                    //take above email and password and pass that event to our auth bloc...
                    context.read<AuthBloc>().add(AutheEventLogIn(email, password));
                  },
                  child: const Text('Login'),
                ),
                TextButton( //hook register button to our Auth Bloc..i.e when register button is tapped, send autheventshouldregister() to the bloc...
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventForgotPassword());
                    },
                    child: const Text('I forgot my password!')),

                TextButton( //hook register button to our Auth Bloc..i.e when register button is tapped, send autheventshouldregister() to the bloc...
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventShouldRegister());
                    },
                    child: const Text('Not registered yet? Register now!!!')),
              ],
            ),
          ),
        ),
    );
  }
}
