//Grab and work with DATABASE..grab new users, create new users...delete new users...find users...
//create notes..delete notes..etc..

//Db Browser sqlite mai sql table bnaye..user ka and Notes ka....

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:notesapp/constant/route.dart';
import 'package:notesapp/services/auth/auth_exception.dart';
import 'package:notesapp/services/auth/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;


class NotesService{
  Database? _db;

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text})async{
      final db= _getDatabaseOrThrow();

      await getNote(id: note.id);

      final updateCount = await db.update(noteTable, {textColumn: text, isSyncedWithCloudColumn: 0});

      if(updateCount ==0){
        throw CouldNotUpdateNote();
      }
      else{
        return await getNote(id: note.id);
      }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async{
    final db= _getDatabaseOrThrow();
    final notes= await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
   
  }

  Future<DatabaseNote> getNote({required int id}) async{
    final db= _getDatabaseOrThrow();
    final notes= await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);

    if(notes.isEmpty){
      throw CouldNotFindNote();
    }
    else{
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async{
    final db= _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async{
    final db=  _getDatabaseOrThrow();
    
    //from noteTable delete an object where it's column id= ? (something) and passing that "something" in whereArgs...
    final deletedCount= await db.delete(noteTable, where: 'id=?', whereArgs: [id]);
    if(deletedCount !=1){
      throw CouldNotDeleteNote();
    }
  }  

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async{
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

    return note;
    
  }

  Future<DatabaseUser> getUser({required String email}) async{
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

  Future<void> open() async{ //opens the database...
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath= await getApplicationDocumentsDirectory();
      final dbPath =join(docsPath.path, dbName); //get actal path of our database...database name will be joined with path of our document folder..
      final db= await openDatabase(dbPath);
      _db= db;

     

      await db.execute(createUserTable);

      

      await db.execute(createNoteTable);
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