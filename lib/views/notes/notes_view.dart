import 'package:flutter/material.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth/crud/notes_services.dart';
import 'package:notesapp/services/auth_service.dart';
import 'package:notesapp/utilities/dialogs/logout_dialog.dart';
import 'package:notesapp/views/notes/note_list_view.dart';

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
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(  //for 3 dots menu options
            onSelected: (value) async {
              switch(value) {
                
                case MenuAction.logout:
                  final shouldLogOut= await showLogOutDialog(context);
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
      body:FutureBuilder( //barebone of our project where user is greated or is retrieved from DB as he/she was...
        future: _notesService.getOrCreateUser(email: userEmail), //create new user or get it by using the email given..
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if(snapshot.hasData){
                        final allNotes= snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note)async{
                            await _notesService.deleteNote(id: note.id); 
                          }, 
                          onTap: (note) {
                            Navigator.of(context).pushNamed(createOrUpdateNoteRoute, arguments: note); 
                          },
                        );
                      }
                      else{
                          return const CircularProgressIndicator();
                      }
                      
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


