import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text){
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title:  const Text('OOps!!'),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.of(context).pop(); //wo jo oops wala dialog alert box aayega uska ok p click karne se 
          },                            //wo dialog box hat jayega...or rather pop ho jayega..and phir login screen 
          child: const Text('OK!'),      //p aajayega!!
        )
      ],
    ) ;
  }) ;
}