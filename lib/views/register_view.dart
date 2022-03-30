import 'dart:developer' as devtools show log;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/constant/route.dart';

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
                final userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                devtools.log(userCredential.toString());
    
              } on FirebaseAuthException 
              catch(e){
                if(e.code== 'weak-password'){
                  devtools.log('weak password');
                }
                else if(e.code== 'email-already-in-use'){
                  devtools.log('Email Already Registered!!!');
                }
                else if(e.code=='invalid-email'){
                  devtools.log('Invalid Email');
                }
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
