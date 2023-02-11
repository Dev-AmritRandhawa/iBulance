

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

import '../model/user_state_authentication.dart';
import '../widgets/indicator.dart';

class PhoneAuthFirebase extends StatefulWidget {
  final String number;
  final String countryCode;
  final TextEditingController previousController;
  final Duration initialDelay = const Duration(seconds: 1);

  const PhoneAuthFirebase(
      {super.key,
      required this.number,
      required this.countryCode,
      required this.previousController});

  @override
  PhoneAuthFirebaseState createState() => PhoneAuthFirebaseState();
}

class PhoneAuthFirebaseState extends State<PhoneAuthFirebase> {
   String _verificationCode = "";
  TextEditingController otpController = TextEditingController();
  GlobalKey<FormState> otpKey = GlobalKey();

  int secondsRemaining = 30;
  bool enableResend = false;
  late Timer timer;

  bool waitingForServer = false;

  @override
  void initState() {
    _mobileAuthFirebase(widget.countryCode + widget.number);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: waitingForServer
          ? Center(child: Indicator.show(context))
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: Image.asset("assets/phoneHeading.png",
                      height: MediaQuery.of(context).size.height / 2.5),
                ),
                const Text(
                  "An one time password has been sent to",
                  style:
                      TextStyle(fontFamily: "QuickSand", color: Colors.black54),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.countryCode + widget.number,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontFamily: "Raleway",
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      child: const Text(
                        "Change Number?",
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Form(
                    key: otpKey,
                    child: PinCodeTextField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter otp";
                        } else if (value.length != 6) {
                          return "Enter 6 digits otp";
                        } else {
                          return null;
                        }
                      },
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      appContext: context,
                      length: 6,
                      onChanged: (String value) {},
                    ),
                  ),
                ),
                Center(
                  child: CupertinoButton(
                    onPressed: () async {
                      if (otpKey.currentState!.validate()) {
                        if (await _signInManual()) {
                          otpController.clear();
                        }
                      }
                    },
                    color: Colors.black,
                    child: const Text(
                      "Proceed",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                enableResend
                    ? TextButton(
                        onPressed: () {
                          secondsRemaining = 30;
                          enableResend = false;
                          _mobileAuthFirebase(widget.number);
                        },
                        child: const Text(
                          "Resend",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: "Raleway",
                          ),
                        ))
                    : TextButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Resend OTP in",
                              style: TextStyle(
                                  color: Colors.black, fontFamily: "Quicksand"),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              secondsRemaining.toString(),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ))
              ],
            ),
    );
  }

  Future<void> _mobileAuthFirebase(String number) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithAutoVerify(credential);
      },
      timeout: const Duration(seconds: 60),
      verificationFailed: (FirebaseAuthException e) async {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.code)));
      },
      codeSent: (verificationId, resendToken) async {
        _verificationCode = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  Future<void> _signInWithAutoVerify(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {});
      _moveScreen();
      widget.previousController.dispose();
    } on FirebaseAuthException catch (e) {
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  Future<bool> _signInManual() async {
    final phoneAuth = PhoneAuthProvider.credential(
        verificationId: _verificationCode, smsCode: otpController.text);
    try {
      setState(() {});
      await FirebaseAuth.instance.signInWithCredential(phoneAuth);
      _moveScreen();
      widget.previousController.dispose();
    } on FirebaseAuthException catch (e) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 5), content: Text(e.code)));
      return true;
    }
    return false;
  }

  void _moveScreen() {

    if (Platform.isIOS) {
      Navigator.of(context).pushAndRemoveUntil(CupertinoPageRoute(
        builder: (context) => const UserStateAuthentication(),
      ),(route) => false,);
    } else if (Platform.isAndroid) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (context) => const UserStateAuthentication(),
      ),(route) => false,);
    }
  }
}
