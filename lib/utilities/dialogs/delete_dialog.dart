import 'package:flutter/material.dart';
import 'package:notesapp/utilities/dialogs/generic_dialogs.dart';

Future<bool> showDeleteDialog(BuildContext context){
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to Delete this Item?',
    optionsBuilder: ()=> {
      'Cancle': false,
      'Yes': true,
    },
  ).then((value) => value ?? false);
}