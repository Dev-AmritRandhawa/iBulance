

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Indicator  {

 static Widget show(BuildContext context) {
    return Container(
      child :
        Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.black))
    );
  }
}
