import 'package:flutter/material.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth/crud/notes_services.dart';
import 'package:notesapp/services/auth_service.dart';

import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({ Key? key }) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currUser!.email!;  // ! ---> force Unwrap that..

  @override
  void initState() {
    _notesService = NotesService();
    //open database.. 
    super.initState();
  }

  @override
  void dispose() { //Close db...
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(  //for 3 dots menu options
            onSelected: (value) async {
              switch(value) {
                
                case MenuAction.logout:
                  final shouldLogOut= await showLogOutDilogue(context);
                  if(shouldLogOut){
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }                     //after goin to note create screen..the back button 
                                        //u see is also there to go to main UI...
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
      body:FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail), //create new user or get it using the email given..
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                      return const Text('Waiting for all Notes...');
                    default: 
                      return const CircularProgressIndicator();
                  }
                },
              );
            default: return  const CircularProgressIndicator();
            
          }
        },
      ),
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
  