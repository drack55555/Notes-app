import 'package:flutter/material.dart';



//the button should have a text and value on it(text button) and a OnPressed ...
typedef DialogOptionBuilder<T> = Map<String, T?> Function (); 
                                    //list of title to display for every button so every button has one title
                                    // stored in this map String along with list of values..so not creating 
                                    //2 different listsand matching every title to every value whose button value is what title...
                                    //...and instead making a map to keep both the lists of
                                    // title and values together mapped for every title with it's value...

//A button code for use so not to create a button everytime of same use i.e asking a yes/no question...
Future<T?> showGenericDialog<T>({required BuildContext context, required String title, 
                                required String content, required DialogOptionBuilder optionsBuilder}){
  final options = optionsBuilder();
  return showDialog(
    context: context,
    builder: (context){
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((optionTitle){
          final T value = options[optionTitle];
          return TextButton(
            onPressed: (){
              if(value!=null){
                Navigator.of(context).pop(value);
              }
              else{
                Navigator.of(context).pop();
              }
            },
            child: Text(optionTitle),
          );
        }).toList(),
      );
    }
  );
}