
//Grab and work with DATABASE..grab new users, create new users...delete new users...find users...
//create notes..delete notes..etc..

//Db Browser sqlite mai sql table bnaye..user ka and Notes ka....

import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:notesapp/extensions/list/filter.dart';
import 'package:notesapp/services/auth/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;


class NotesService{
  Database? _db;

  List<DatabaseNote> _notes = []; //this is our cache where all notes will be kept...
  //everything from outside will be read using streamcontroller.._notes just going to hold notes....
  //this streamcontroller will be the pipe for _notes .....broadcast--listen to the changes done to the streamcontroller...

  DatabaseUser? _user;

  static final NotesService _shared= NotesService._sharedInstance();
  NotesService._sharedInstance(){
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: (){
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController ;

//this allNotes will subscribe to _notesStreamController and get all notes from that controller..
//as the StreamController contains the _notes=[] thing which holds all notes..
  Stream<List<DatabaseNote>> get allNotes{
    return _notesStreamController.stream.filter((note) {
      final currentUser= _user;    //Stream contains  List of Notes but here note is getting one note..
      if(currentUser!= null){       //...at a time..this is the Beauty of Creating our own extensions..
        return note.userId == currentUser.id;  //...we can droll down our existing object an grab whatever we need from it using extensions..
      }   
      else{
        throw UserShouldBeSetBeforeReadingAllNotes();
      }     //if you are reading all Notes from this interface you need to make sure that the current user was set when called..
            //..u called this fucntion..
    });   
  }                          

  //get the user from database and if user doesn't exist, we're gonna create that user..
  //and then return that fetched or created user back to the caller..
  Future<DatabaseUser> getOrCreateUser({required String email, bool setAsCurrentUser = true})async{
    try {
      final user= await getUser(email: email);// is we could retrieve that user from the DB..
      if(setAsCurrentUser){//.. and this bool is true..
        _user = user;//...the we set our own user to this user...
      }
      return user;
    } 
    on CouldNotFindUser{
      final createdUser= await createUser(email: email);// otherwise if we have to create the user..
      if(setAsCurrentUser){//...and this is True...
        _user= createdUser;//..then we set this 'current user' to the CreatedUser...
      }
      return createdUser;
    }
    catch (e){
      rethrow; 
    }
    

  }

  //purpose of _cacheNotes is to read all the notes from database and place in notesstreamcontroller....
  Future<void> _cacheNotes() async{
    final allNotes = await getAllNotes(); 
    //here allNotes will be Iterable as getAllNotes return one...so convert it to list then add to _notes..
    _notes= allNotes.toList();
    _notesStreamController.add(_notes); //telling stream controller, hey, here's a new value....


  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text})async{
    await _ensureDbIsOpen();
    final db= _getDatabaseOrThrow();

    //make sure note exists..
    await getNote(id: note.id);

    //updated the DB...
    final updateCount = await db.update(
      noteTable,
      {textColumn: text, isSyncedWithCloudColumn: 0},
      where: 'id = ?', whereArgs: [note.id], //ye add kiye tb ja kr hr note same ni hojayega after hot reload...
      );         //..and bss ussi ka note update hoga jiska id avi hai apne pass...
    

    if(updateCount ==0){
      throw CouldNotUpdateNote();
    }
    else{
      final updatedNote=  await getNote(id: note.id); //we have updated the database..and to get that updated one we call getNode()..
      //now update local cache...by removing the old one and..
        _notes.removeWhere((note) => note.id == updatedNote.id);
        _notes.add(updatedNote); //...and adding the updated note..
        _notesStreamController.add(_notes);
        return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async{
    await _ensureDbIsOpen();
    final db= _getDatabaseOrThrow();
    final notes= await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
   
  }
    //to get updated things from database...
  Future<DatabaseNote> getNote({required int id}) async{
    await _ensureDbIsOpen();
    final db= _getDatabaseOrThrow();
    //upon we trying to read a note from database, we are just making a query to database and if we can find that item 
    //we are returning that by creating a DatabaseNote from a Row...
    final notes= await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);

    if(notes.isEmpty){
      throw CouldNotFindNote();
    }
    else{
      final note= DatabaseNote.fromRow(notes.first); //new note..
      _notes.removeWhere((note) =>note.id == id);//we are removing the old note(using its Id)which needs to be updated and..
      _notes.add(note);         //...and adding the new note just got...this is updating in local cache..
      _notesStreamController.add(_notes); //and then updating it to the world ..i.e. UI for everyone to see..

      return note;
    }
  }

  Future<int> deleteAllNotes() async{
    final db= _getDatabaseOrThrow();
    final numberOfDeletion= await db.delete(noteTable);

    _notes= []; //local cache v update ho gya ki sara notes delete ho gya hai..
    _notesStreamController.add(_notes); // added to stream controller to reflect/update in the UI..

    return numberOfDeletion;
  }

  Future<void> deleteNote({required int id}) async{
    await _ensureDbIsOpen();
    final db=  _getDatabaseOrThrow();
    
    //from noteTable delete an object where it's column id= ? (something) and passing that "something" in whereArgs...
    final deletedCount= await db.delete(noteTable, where: 'id=?', whereArgs: [id]);
    if(deletedCount ==0){
      throw CouldNotDeleteNote();
    }else{
        _notes.removeWhere((note)=> note.id == id); //remove that note from local cache..
        _notesStreamController.add(_notes);
    }
  }  

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async{
    await _ensureDbIsOpen();
    final db= _getDatabaseOrThrow();
    
    //make sure owner exists in the database with correct id...
    final dbUser= await getUser(email: owner.email);
    if(dbUser!= owner){
      throw CouldNotFindUser();
    }
    
    const text='';

    //Create the NOTE..
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1
      }
    );
    
    final note= DatabaseNote(
      id: noteId,
      userId:owner.id,
      text: text,
      isSyncedWithCloud: true
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
    
  }

  Future<DatabaseUser> getUser({required String email}) async{
    await _ensureDbIsOpen();
    final db= _getDatabaseOrThrow();
    
    final result = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs:  [email.toLowerCase()]);  

    if(result.isEmpty){
      throw CouldNotFindUser();
    }
    else{
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email})async {
    final db= _getDatabaseOrThrow();

    //.query used as we are using email to create a new user for the database...
    final result = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs:  [email.toLowerCase()]);  
    if(result.isNotEmpty){
      throw UserAlreadyExists();
    }

    final userId= await db.insert(userTable, {emailColumn: email.toLowerCase()}); 
    return DatabaseUser(id: userId, email: email); 
  }

  Future<void> deleteUser({required String email}) async{
    await _ensureDbIsOpen();
    final db= _getDatabaseOrThrow();
    final deletedCount= await db.delete(userTable, where: 'email=?', whereArgs: [email.toLowerCase()]);
    if(deletedCount !=1){
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow(){
    final db= _db;
    if(db==null){
      throw DatabaseIsNotOpen();
    }
    else{
      return db;
    }
  }

  Future<void> close() async{ //close db...
    final db= _db;
    if(db==null){
      throw DatabaseIsNotOpen();
    }
    else{
      await db.close();
      _db= null;
    }
  }

  Future<void> _ensureDbIsOpen() async{
    try{
      await open();
    }
    on DatabaseAlreadyOpenException{
      
    }
  }

  Future<void> open() async{ //opens the database...
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath= await getApplicationDocumentsDirectory();
      final dbPath =join(docsPath.path, dbName); //get actal path of our database...database name will be joined with path of our document folder..
      final db= await openDatabase(dbPath);
      _db= db;
      //create user table..
      await db.execute(createUserTable);
      //create note table..
      await db.execute(createNoteTable);
      await _cacheNotes(); //means...after creating all tables place the notes in cache..
    }
    on MissingPlatformDirectoryException{
      throw UnableToGetDocumentDirectory();
    }
  }

}



@immutable //since constructor is const we can tag it as Immutable..
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map) : id= map[idColumn] as int, email= map[emailColumn] as String;

  @override
  String toString() {
    return 'Person, Id= $id, email= $email';
  }

  @override
  bool operator== (covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;


}

class DatabaseNote{
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map) : 
    id= map[idColumn] as int,
    userId= map[userIdColumn] as int,
    text= map[textColumn] as String,
    isSyncedWithCloud= (map[isSyncedWithCloudColumn] as int) ==1? true : false;

  @override
  String toString() {
    return 'Notes, ID= $id, userId= $userId, isSyncedWithCloud = $isSyncedWithCloud, text= $text';

  }
  
  @override
  bool operator== (covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;


}

const dbName= 'notes.db'; //files under which our database is gonna saved..
const noteTable= 'note';  //table name as defined in Db browser
const userTable= 'user';  //table name as defined in Db browser
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn= 'user_id';
const textColumn= 'text';
const isSyncedWithCloudColumn= 'is_synced_with_cloud';
 
 //create the database(user and note table) if not able to open database because it didn't exist...

const createUserTable= '''CREATE TABLE IF NOT EXISTS "user" (
  
  "id"	INTEGER NOT NULL,
  "email"	TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id" AUTOINCREMENT)
); ''';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
  "id"	INTEGER NOT NULL,
  "user_id"	INTEGER NOT NULL,
  "text"	TEXT,
  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY("id" AUTOINCREMENT),
  FOREIGN KEY("user_id") REFERENCES "user"("id")
); ''';