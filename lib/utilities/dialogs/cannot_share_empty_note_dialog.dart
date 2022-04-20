import 'dart:ffi';

import 'package:flutter/widgets.dart';
import 'package:notesapp/utilities/dialogs/generic_dialogs.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context){
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty Note',
    optionsBuilder: () => {  //a function that return a MAP...OPTION BUILDER... 
      'OK': null,
    }
  );
}