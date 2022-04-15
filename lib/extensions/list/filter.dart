
//This function allows us to filter a Stream of List of SOmething(here list of Notes)...
//..and our Where clause is gonna get that something and if That something passes the test..
//...then that will be included in the final List..
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where){ //this 'where' specifies the TEST...
    return map((items)=> items.where(where).toList());
  }
}
// Basically this is for not making all the notes available to all the users..
//and only those notes are shown which belong to the current user...