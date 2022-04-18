 //a super class for all our cloud exceptions.... A Parent Exception,,,inheritance
 class  CloudStorageException implements Exception{
   const CloudStorageException();
 }

//if firebase firestore is not able to create that note we will throw this exception..
class CouldNotCreateNoteException extends CloudStorageException{} //C of Crud

//all the notes displayed of user may not be able to retrieve from the Cloud DB so exception..
class CouldNotGetAllNotesException extends CloudStorageException{} // R of crud


class CouldNotUpdateNoteException extends CloudStorageException{}  //U of crud


class CouldNotDeleteNoteException extends CloudStorageException{} //D in crud.. 