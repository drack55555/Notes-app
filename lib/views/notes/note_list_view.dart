import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/crud/notes_services.dart';
import 'package:notesapp/utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeleteNote;
  
  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index){
        final note = notes[index];// current note jis p hai wo..
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async{
              final shouldDelete = await showDeleteDialog(context);
              if(shouldDelete){
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}