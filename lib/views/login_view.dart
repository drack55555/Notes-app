import 'dart:developer' as devtools show log;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


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
                await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                  Navigator.of(context).pushNamedAndRemoveUntil('/notes/', (route) => false);
              } on FirebaseAuthException
              catch(e){
                  if(e.code=='user-not-found'){
                    devtools.log('Invalid User!');
                  }
                  else if(e.code=='wrong-password'){
                    devtools.log('Wrong password!!!');
                  }
              }                                                                 
            },
            child:const Text('Login'),  
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil('/register', (route) => false);
          },
          child: const Text('Not registered yet? Register now!!!')
          ),
        ],
      ),
    );
  }
  

  
}
