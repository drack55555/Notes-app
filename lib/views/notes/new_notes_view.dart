import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({ Key? key }) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNotesViewtate();
}

class _NewNotesViewtate extends State<NewNoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: const Text('Write your note here...'),
    
      
    );
  }
}