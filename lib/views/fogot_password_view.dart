import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';
import 'package:notesapp/utilities/dialogs/error_dialog.dart';
import 'package:notesapp/utilities/dialogs/password_reset_email_send_dialog.dart';



class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({ Key? key }) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {

  late final TextEditingController _controller;

  @override
  void initState(){
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if(state is AuthStateForgotPassword){
          if(state.hasSendEmail){
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if(state.exception!=null){
            await showErrorDialog(context, 'We could not process your request! Please make sure you are a registered user.');
          }
        }
      },  
      child: Scaffold(
        appBar: AppBar(title: const Text('Forgot Password'),
        ),
        body: Padding(
          padding:const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('We could not process your request! Please make sure you are a registered user.'),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Your email address.....',
                ),
              ),
              TextButton(
                onPressed: (){
                  final email= _controller.text;
                  context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                },
                child: const Text('Send me password reset link'),
              ),
              TextButton(
                onPressed: (){
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text('Back to Login Page'),
              ),
            ],
          ),
          ),
      ),
    );
  }
}