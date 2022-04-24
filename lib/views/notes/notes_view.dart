import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth/bloc/auth_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth_service.dart';
import 'package:notesapp/services/cloud/cloud_note.dart';
import 'package:notesapp/services/cloud/firebase_cloud_storage.dart';
import 'package:notesapp/utilities/dialogs/logout_dialog.dart';
import 'package:notesapp/views/notes/note_list_view.dart';
import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({ Key? key }) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currUser!.id;  // ! ---> force Unwrap that..

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    //open database.. 
    super.initState();
  }

  // @override
  // void dispose() { //Close db... 
  //   _notesService.close();
  //   super.dispose();
  // }

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
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }                     //on receiving the auth Log out event..it will go to login screen
                                        // automatically because of it's code...
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
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
            case ConnectionState.active:
              if(snapshot.hasData){
                final allNotes= snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note)async{
                    await _notesService.deleteNote(documentId: note.documentId);
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
      )
    );
  }
}


