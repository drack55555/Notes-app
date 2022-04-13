import 'package:flutter/widgets.dart';
import 'package:notesapp/utilities/dialogs/generic_dialogs.dart';

Future<void> showErrorDialog(BuildContext context, String text){
  
  return showGenericDialog<void>(
    context: context,
    title: 'An error Occurred!',
    content: text, optionsBuilder:()=>{
      'OK' :null
    },
  );

}