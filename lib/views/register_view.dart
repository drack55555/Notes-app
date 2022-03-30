import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/constant/route.dart';
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
                await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                final user= FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);//yaha pushNamed esi liye used kuki agar email
                                   //maan lo galt daal iye ya change krna ho to upar ek back button aajayega taki
              }                      //verification page se wapas register page p ja k to put correct email...
              on FirebaseAuthException catch(e){    
                if(e.code== 'weak-password'){
                  await showErrorDialog(context, 'Weak Password! Errr!'); 
                }
                else if(e.code== 'email-already-in-use'){
                  await showErrorDialog(context, 'Email Already Registered!!!');
                }
                else if(e.code=='invalid-email'){
                  await showErrorDialog(context, 'Invalid Email');
                }
                else{
                await showErrorDialog(context, 'Error ${e.code}');
                }
              }
               catch (e){
                 await showErrorDialog(context, e.toString());
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
