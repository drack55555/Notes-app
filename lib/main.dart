import 'package:flutter/material.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth_service.dart';
import 'package:notesapp/views/login_view.dart';
import 'package:notesapp/views/notes_view.dart';
import 'package:notesapp/views/register_view.dart';
import 'package:notesapp/views/verify_email_view.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized(); //firebase suru mai he initialized hojayega 
  runApp(MaterialApp(               // onButtonPressed p initialize krne se phle and better 
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',        //way hai for case ki agar boht firebase related
      theme: ThemeData(             //onpressbutton hai to baar baar initialize ka
        primarySwatch: Colors.green,    //tension ni.
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context)=> const LoginView(),
        registerRoute: (context)=> const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
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
        future: AuthService.firebase().initialize(),            //register screen bnana tha(line 6 in MAIN.dart)...
        builder: (context, snapshot) {      //ye phle hojao phir aage ka build kro  //jab future finished ho chuka work krna
          switch(snapshot.connectionState){  
            case ConnectionState.done:      //jab initialize ho chuka to kaam kro ab
              final user= AuthService.firebase().currUser;
              if(user != null){
                if(user.isEmailVerified){
                  return const NotesView();
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



            //agar ye 'this' ni daalenge to error dega dart because hmlog phone button use kr k boolean return 
            // type ko bool return krne se rok rhe hai to mtlb bool return ni ho rha so kaise function ko
            // bool return type diye hai...so to solve this issue we use 'this'....