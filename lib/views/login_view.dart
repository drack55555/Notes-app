import 'dart:html';

import 'package:flutter/material.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth/auth_exception.dart';
import 'package:notesapp/services/auth_service.dart';
import '../utilities/show_error_dialog.dart';


class LoginView extends StatefulWidget {
  const LoginView({ Key? key }) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email= TextEditingController();
    _password= TextEditingController();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Login Here!')),
      body: Column(                 
        children: [                  
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
              final email= _email.text;
              final password= _password.text;
              try {   //sign in agar hua to 'Notes' screen mai Navigate krna...ni to catch trigger hoga..
                await AuthService.firebase().logIn(email: email, password: password);                
                final user= AuthService.firebase().currUser;
                if(user?.isEmailVerified ?? false){ //agar email verified hai to go to notes main screen
                  Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                }
                else{ //wrna go to verify screen
                  Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
                }
              } 
              on UserNotFoundAuthException{
                await showErrorDialog(context, 'User not Found!');
              }
              on WrongPasswordAuthException{
                await showErrorDialog(context, 'Wrong Password');
              }
              on GenericAuthException{
                await showErrorDialog(context, 'Authentication Error!');
              }                                         
            },
            child:const Text('Login'),  
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          },
          child: const Text('Not registered yet? Register now!!!')
          ),
        ],
      ),
    );
  }
}



