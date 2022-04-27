import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/bloc/auth_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth_service.dart';
import '../constant/route.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({ Key? key }) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text('Verify Email!')),
      body: Column(
          children: [   //double quotes used because of single quoted word..We've....
            const Text("We've send you an EMAIL verification. Please verify your account"), 
            const Text('If not received the veifiction, click below!'),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventSendEmailVerification()); //bloc mai chala gya sendemail verification ka process ab..
              },
              child: const Text('Resend the EMAIL verification') 
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut()); 
              },
              child: const Text('Restart')
            )
          ],
        ),
    );
  }
}