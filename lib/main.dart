import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/login_view.dart';
import 'package:notesapp/register_view.dart';
import 'package:notesapp/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //firebase suru mai he initialized hojayega 
  runApp(MaterialApp(               // onButtonPressed p initialize krne se phle and better 
      title: 'Flutter Demo',        //way hai for case ki agar boht firebase related
      theme: ThemeData(             //onpressbutton hai to baar baar initialize ka
        primarySwatch: Colors.green,    //tension ni.
      ),
      home: const HomePage(),
      routes: {
        '/login': (context)=> const LoginView(),
        '/register': (context)=> const RegisterView(),
      },
    ),
  );
}
    //All details for Register will be here in RegisterView.....
    //All details for Login will be here in LoginView.....


    //Now Homepage p he register and login ka rahega..login/register jo krna kro....
class HomePage extends StatelessWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(     //ye kra kuki firebase initialize sbse phle krna
          options: DefaultFirebaseOptions.currentPlatform,   //tha and us k baad he login/
        ),                                  //register screen bnana tha(line 6 in MAIN.dart)...
        builder: (context, snapshot) {      //ye phle hojao phir aage ka build kro  //jab future finished ho chuka work krna
          switch(snapshot.connectionState){  
            case ConnectionState.done:      //jab initialize ho chuka to kaam kro ab
              final user= FirebaseAuth.instance.currentUser;
              if(user != null){
                if(user.emailVerified){
                  return const  Text('Email Verified!!SABASH!!');
                }
                else{
                  return const VerifyEmailView();
                }
              }
              else{
                return const LoginView();
              }
              
            default: return const CircularProgressIndicator();
          }
          
        }
      );
  }
}

