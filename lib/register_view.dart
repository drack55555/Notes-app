
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/firebase_options.dart';

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
      appBar: AppBar(title: const Text("Register"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(     //ye kra kuki firebase initialize sbse phle krna
          options: DefaultFirebaseOptions.currentPlatform,   //tha and us k baad he login/
        ),                                  //register screen bnana tha(line 6 in MAIN.dart)...
        builder: (context, snapshot) {      //ye phle hojao phir aage ka build kro 
          switch(snapshot.connectionState){
            case ConnectionState.done:       //jab future finished ho chuka work krna
              return Column(                 //tb jakr Column and login page bnao
                children: [                  // wrna LOADING message show kro bss
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
                        print(userCredential);

                      } on FirebaseAuthException 
                      catch(e){
                        if(e.code== 'weak-password'){
                          print('weak password');
                        }
                        else if(e.code== 'email-already-in-use'){
                          print('Email Already Registered!!!');
                        }
                        else if(e.code=='invalid-email'){
                          print('Invalid Email');
                        }
                      } 
                    },
                    child:const Text('Register'),  
                  ),
                ],
              );
              default: return const Text('Loading.....');
          }
          
        }
      ),
    );
  }
}
