import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/views/login_view.dart';
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

enum MenuAction{ logout }  

class NotesView extends StatefulWidget {
  const NotesView({ Key? key }) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(  //for 3 dots menu options
            onSelected: (value) async {
              switch(value) {
                
                case MenuAction.logout:
                  final shouldLogOut= await showLogOutDilogue(context);
                  if(shouldLogOut){
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
              }
            },  
            itemBuilder: (context){
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,  //kaam kya hoga wo 3 dot mai jo v aya uska...bss programmer ko dikhega..
                  child: Text('Log out'), // ye dikhaega user ko mention krte hue use of the thing spawned...
                )
              ];
            },
          )
        ],
      ),
      body: const Text('hello nubs'),
    );
  }
}


Future<bool> showLogOutDilogue(BuildContext context){
  return showDialog<bool>(
    context: context,
    builder: (context){
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
            ),
            TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false); //agar wo logout dilogue box k jagh phone ka back button use kr liya and 
}             //dilogue box ko he band kr diya without choosing "yes-logout" or "no"..tb return false..
            //wrna if chosen a value i.e. "yes-logout" or "no" tb to koi dikkat he ni..tb return that value....
            //agar ye 'this' ni daalenge to error dega dart because hmlog phone button use kr k boolean return 
            // type ko bool return krne se rok rhe hai to mtlb bool return ni ho rha so kaise function ko
            // bool return type diye hai...so to solve this issue we use 'this'....