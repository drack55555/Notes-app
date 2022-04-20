
import 'package:flutter/material.dart';
import 'package:notesapp/services/auth_service.dart';
import 'package:notesapp/services/cloud/cloud_note.dart';
import 'package:notesapp/services/cloud/cloud_storage_constants.dart';
import 'package:notesapp/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:notesapp/utilities/generics/get_argument.dart';
import 'package:notesapp/services/cloud/cloud_storage_exceptions.dart';
import 'package:notesapp/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({ Key? key }) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {

  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override 
  void initState(){
    _notesService = FirebaseCloudStorage();
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
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  //In this..we see if we have created this note before just return but if not created then create it and get back to us..
  Future<CloudNote> createOrGetExistingNote() async{

    final widgetNote= context.getArgument<CloudNote>();
    if(widgetNote != null) { //meaning user tapped on existing note and ended up on the screen
      _note= widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }
    
    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }
    //creation of new Notes..
    final currUser = AuthService.firebase().currUser!;
    final userId= currUser.id;
    final newNote=  await _notesService.createNewNote(ownerUserId: userId);
    _note= newNote;
    return newNote;
  }

  //if pressed + icon to create note but wrote nothing(left empty) and pressed back button then don't create that note..delete it cause it's an empty note..
  void _deleteNoteIfTextIsEmpty(){
    final note= _note;
    if(_textController.text.isEmpty && note != null){
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  //saving the note if there is text in it ...
  Future<void> _saveNoteIfTextNotEmpty() async {
    final note= _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty){
      await _notesService.updateNote(documentId: note.documentId, text: text);
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
        actions: [
          IconButton(
            onPressed:() async {
              final text = _textController.text;
              if(_note== null || text.isEmpty){
                await showCannotShareEmptyNoteDialog(context);
              }
              else{
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(),
        builder: (context,snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.done:
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