import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/crud/notes_services.dart';
import 'package:notesapp/services/auth_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({ Key? key }) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNotesViewtate();
}

class _NewNotesViewtate extends State<NewNoteView> {

  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override 
  void initState(){
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  // this will take the current node and if it exists then it gonna take the current textEditingController...
  //..text and update that Note in Database...
  void _textControllerListener() async{
    final note = _note; 
    if(note== null){
      return ;
    }
    final text = _textController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  //In this..we see if we have created this note before just return but if not created then create it and get back to us..
  Future<DatabaseNote> createNewNote() async{
    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }
    //creation of new Notes..
    final currUser = AuthService.firebase().currUser!;
    final email = currUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  //if pressed + icon to create note but wrote nothing(left empty) and pressed back button then don't create that note..delete it cause it's an empty note..
  void _deleteNoteIfTextIsEmpty(){
    final note= _note;
    if(_textController.text.isEmpty && note != null){
      _notesService.deleteNote(id: note.id);
    }
  }

  //saving the note if there is text in it ...
  Future<void> _saveNoteIfTextNotEmpty() async {
    final note= _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty){
      await _notesService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context,snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote; //this is how we get our notes from our snapshot
              _setupTextControllerListener();
              return TextField( //text field will send msg to texteditingController and say that it's text has changed..
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...'
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        }
      ),
    );
  }
}