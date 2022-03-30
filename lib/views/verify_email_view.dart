
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser; //getting user to whom verification is to be sent.
                await user?.sendEmailVerification();
              },
              child: const Text('Resend the EMAIL verification') 
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Restart')
            )
          ],
        ),
    );
  }
}