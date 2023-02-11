

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InternetError{
 BuildContext context;
 InternetError(this.context);

 void show(){
  if(Platform.isIOS){
    showCupertinoDialog(context: context, builder: (context) => alert(),barrierDismissible: true);
  }if(Platform.isAndroid){
    showDialog(context: context, builder: (context) => alert(),barrierDismissible: false);
  }
}
 Widget alert(){
  return Platform.isIOS ? CupertinoAlertDialog(
    title: const Text("No connectivity"),
    content: const Text("You are not connected with internet"),
    actions: [
      TextButton(onPressed: (){
        Navigator.pop(context);
      }, child: const Text("Dismiss"))
    ],
  ): AlertDialog(
    title: const Text("No connectivity"),
    content: const Text("Please check your internet connection"),
    actions: [
      TextButton(onPressed: (){
        Navigator.pop(context);
      }, child: const Text("Ok"))
    ],
  );
}


}