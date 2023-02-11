

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/indicator.dart';

class DeleteAccountRequest extends StatefulWidget {
  const DeleteAccountRequest({super.key});

  @override
  DeleteAccountRequestState createState() => DeleteAccountRequestState();
}

class DeleteAccountRequestState extends State<DeleteAccountRequest> {
  bool _loading = false;
  User? user = FirebaseAuth.instance.currentUser;
  late String _verificationCode;
  TextEditingController numberField = TextEditingController();
  GlobalKey<FormState> phoneAuthKey = GlobalKey<FormState>();
  TextEditingController otpController = TextEditingController();
  GlobalKey<FormState> otpKey = GlobalKey();

  bool _state = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text(
              "Account delete request",
              style: TextStyle(fontFamily: "Ubuntu", fontSize: 18),
            ),
          ),
          const Text(
            "You are leaving us.",
            style: TextStyle(
                fontFamily: "Ubuntu", fontSize: 14, color: Colors.black45),
          ),
          Image.asset("images/delete.png"),
          Container(
              child: _state
                  ? Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Form(
                        key: otpKey,
                        child:  TextFormField(
                         ),
                      ),
                    )
                  : null),
          Container(
            child:_state ? CupertinoButton(
                color: Colors.red,
                child: const Text("Confirm",style: TextStyle(color: Colors.white),), onPressed: (){
                  _deleteUser();

            }) :CupertinoButton(
                color: Colors.black,
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  setState(() {
                    _loading = true;
                    _state = true;
                  });
                  if(otpKey.currentState!.validate()){
                    _signInManual();
                  }
                }),
          ),
          Container(
            child: _loading ? Indicator.show(context) : null,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40, right: 15, left: 15),
            child: Text(
              "By clicking delete button, We will erase all of your data and purchases from our database.",
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black45, fontFamily: "Ubuntu"),
            ),
          )
        ],
      ),
    );
  }

  Future<void> onGoBack(value) async {
    setState(() {

    });
    if (value) {
      _deleteUser();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Need to verify first"),
      ));
    }
  }

  Future<void> _deleteUser() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete().then((value) => (){
       //not yet implement
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _signInManual() async {
    try {
      final phoneAuth = PhoneAuthProvider.credential(
          verificationId: _verificationCode, smsCode: otpController.value.text);
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(phoneAuth);
      setState(() {
        _loading = false;
        _state = true;
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 5), content: Text(e.message.toString())));
    }
  }
}
