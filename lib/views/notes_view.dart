import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth_service.dart';

import '../enums/menu_action.dart';

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
                    await AuthService.firebase().logOut();
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
  