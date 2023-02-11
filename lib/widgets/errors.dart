
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Error{
  final BuildContext _context;
  final String _title;
  final String _content;
  final String _errorRight;


  Error(this._context, this._title,this._content, this._errorRight);

  void show(Widget className){
    if(Platform.isIOS){
      showCupertinoDialog(context: _context, builder: (context) => _alert(className),barrierDismissible: false);
    }if(Platform.isAndroid){
      showDialog(context: _context, builder: (context) => _alert(className),barrierDismissible: false);
    }
  }
  Widget _alert(Widget className){
    return Platform.isIOS ? CupertinoAlertDialog(
      content: Text(_content),
      title: Text(_title),
      actions: [
        TextButton(onPressed: (){
          Navigator.pushReplacement(_context, MaterialPageRoute(builder: (context) => className,));
        }, child: Text(_errorRight)),
      ],
    ):AlertDialog(
      title: Text(_title),
      content: Text(_content),
      actions: [
        TextButton(onPressed: (){
          Navigator.pushReplacement(_context, MaterialPageRoute(builder: (context) => className,));
        }, child: Text(_errorRight)),
      ],
    );
  }


}