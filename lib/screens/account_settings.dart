import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/delete_request.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});


  @override
  AccountSettingsState createState() => AccountSettingsState();
}

class AccountSettingsState extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              children: [

                layout()
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget layout() {
    return Padding(
      padding: const EdgeInsets.only(top: 50,left: 20,right: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () {
                if (Platform.isIOS) {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) =>
                          const DeleteAccountRequest(
                          )));
                }
                      if (Platform.isAndroid){
                    Navigator
                        .of(context)
                        .push(MaterialPageRoute(
                        builder: (context) =>
                           const DeleteAccountRequest(
                            )));
                    }
                    },
                  child: const Text(
                    "Delete account", style: TextStyle(color: Colors.black),)),
              const Icon(Icons.arrow_forward_ios)
            ],
          ),
          const Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Divider(
                color: Colors.black54,
                height: 10,
              ))
        ],
      ),
    );
  }
}
