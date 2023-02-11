import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibulance/screens/phone_authentication.dart';

class MobileAuthentication extends StatefulWidget {
  const MobileAuthentication({super.key});

  @override
  MobileAuthenticationState createState() => MobileAuthenticationState();
}

class MobileAuthenticationState extends State<MobileAuthentication> {
  String countryCode = "+91";
  TextEditingController numberField = TextEditingController();
  GlobalKey<FormState> phoneAuthKey = GlobalKey<FormState>();
  final Duration initialDelay = const Duration(seconds: 1);

  bool widgetsState = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          widgetsState
              ? DelayedDisplay(
                  delay: Duration(seconds: initialDelay.inSeconds),
                  child: const Text(
                    "Continue with number",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Poppins",
                    ),
                  ),
                )
              : const SizedBox(height: 5),
          Flexible(
              child: Image.asset(
            "assets/otpHeading.png",
            height: MediaQuery.of(context).size.height / 3,
          )),
          widgetsState
              ? DelayedDisplay(
                  delay: Duration(seconds: initialDelay.inSeconds),
                  child: const Text(
                    "You'll receive a 6 digit code \n to verify next",
                    style: TextStyle(
                        fontFamily: "Quicksand",
                        color: Colors.black45,
                        fontSize: 18),
                  ),
                )
              : const SizedBox(height: 5),
          Center(
            child: SizedBox(
              height: 80,
              width: MediaQuery.of(context).size.width / 1.2,
              child: Form(
                key: phoneAuthKey,
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Phone number required.";
                    } else if (value.length < 10) {
                      return "Enter 10 digits.";
                    } else {
                      return null;
                    }
                  },
                  controller: numberField,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: InputDecoration(
                      prefixIcon: CountryCodePicker(
                        onChanged: (value) {
                          countryCode = value.toString();
                        },
                        initialSelection: 'IN',
                        favorite: const ['+91', 'IN'],
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                      border: const OutlineInputBorder(),
                      hintText: "Number",
                      hintStyle: const TextStyle(color: Colors.black),
                      labelStyle: const TextStyle(color: Colors.black)),
                  onTap: () {
                    setState(() {
                      widgetsState = false;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      widgetsState = true;
                      FocusManager.instance.primaryFocus?.unfocus();
                    });
                  },
                ),
              ),
            ),
          ),
          CupertinoButton(
            onPressed: () {
              if (phoneAuthKey.currentState!.validate()) {
                if (Platform.isIOS) {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PhoneAuthFirebase(
                            number: numberField.text,
                            countryCode: countryCode,
                            previousController: numberField),
                      ));
                } else if (Platform.isAndroid) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhoneAuthFirebase(
                            number: numberField.text,
                            countryCode: countryCode,
                            previousController: numberField),
                      ));
                }
              }
            },
            color: Colors.redAccent,
            child: const Text(
              "Proceed",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ]));
  }
}
