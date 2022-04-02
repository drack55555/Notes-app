import 'package:flutter/material.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth/auth_exception.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth_service.dart';
import 'package:notesapp/utilities/show_error_dialog.dart';

//All details for Register will be here in RegisterView.....


class RegisterView extends StatefulWidget {
  const RegisterView({ Key? key }) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register!')),
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
              try {
                AuthService.firebase().createUser(email: email, password: password);
 
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);//yaha pushNamed esi liye used kuki agar email
                                   //maan lo galt daal iye ya change krna ho to upar ek back button aajayega taki
              } 
              on WeakPasswordAuthException{
                await showErrorDialog(context, 'Weak Password! Errr!'); 
              }    
              on EmailAlreadyInUseAuthException{
                await showErrorDialog(context, 'Email Already Registered!!!');
              }
              on InvalidEmailAuthException{
                await showErrorDialog(context, 'Invalid Email');
              }
              on GenericAuthException{
                await showErrorDialog(context, 'Failed to Register!');
              } 
            },
            child:const Text('Register'),  
          ),
          TextButton(
            onPressed: (){  //push...Until wala click krne k baad kaha jana(Nagivate) wo batata...
              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
          },
            child: const Text('Already Registered!? Login Here!')
          ),
        ],
      ),
    );
  }
}