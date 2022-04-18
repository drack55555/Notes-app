import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:notesapp/services/cloud/cloud_note.dart';
import 'package:notesapp/services/cloud/cloud_storage_constants.dart';
import 'package:notesapp/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage{// This is how you taalk with firestore.
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async{
    try {
      notes.doc(documentId).delete();      
    }
    catch(e){
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({required String documentId, required String text}) async {
    try{
      await notes.doc(documentId).update({textFieldName: text});
    }
    catch (e){
      throw CouldNotUpdateNoteException();
    }
  }

  //if we wanna grab a stream of data regularly changing then we use the 'snapshot'...
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}){
    return notes.snapshots().map((event) =>
       event.docs.map((doc) => CloudNote.fromSnapshot(doc))
      .where((note) => note.ownerUserId == ownerUserId));
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async{
    try{
      //fields you want to where search on...so search for all notes which are for this ownerUserId..
      return await notes
      .where(ownerUserIdFieldName,isEqualTo: ownerUserId)
      .get()
      .then((value) => value.docs.map((doc){
        return CloudNote(
          documentId: doc.id,
          ownerUserId: doc.data()[ownerUserIdFieldName] as String,
          text: doc.data()[textFieldName] as String,  
        );       
      }
      ));
    }
    catch(e){
      throw CouldNotGetAllNotesException();
    }
  }

  void createNewNote({required String ownerUserId}) async{

    //everything you add here will be packaged in a DOCUMENT that will be stored in your cloud firebase account..
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  static final FirebaseCloudStorage _shared= FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

}

