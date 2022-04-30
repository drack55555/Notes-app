import 'package:flutter/widgets.dart';
import 'package:notesapp/utilities/dialogs/generic_dialogs.dart';


Future<void> showPasswordResetSentDialog(BuildContext context){
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content:'We have now sent a password reset link. Please check your email for more instructions.', 
    optionsBuilder: () =>{
      'OK': null,
    }
  );
}