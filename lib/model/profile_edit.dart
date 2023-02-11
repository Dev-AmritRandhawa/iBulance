
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/indicator.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  ProfileEditState createState() => ProfileEditState();
}

class ProfileEditState extends State<ProfileEdit> {
  String _email = "";
  String _name = "";
  bool _loading = true;

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _nameKey = GlobalKey<FormState>();

  final GlobalKey<FormState> _emailKey = GlobalKey<FormState>();

  Future<void> _display() async {
    FirebaseFirestore server = FirebaseFirestore.instance;
    await server
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        _name = documentSnapshot.get("name");
        _email = documentSnapshot.get("email");
        _nameController.text = documentSnapshot.get("name");
        _emailController.text = documentSnapshot.get("email");

      }
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void initState() {
_display();
super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: _loading
              ? Center(child: Indicator.show(context))
              : Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            "images/profile.png",
                            width: 120,
                            height: 120,
                          ),
                          TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Coming soon"),
                                ));
                              },
                              child: const Text("Change photo")),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _nameKey,
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter your name";
                                  } else {
                                    return null;
                                  }
                                },
                                controller: _nameController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintStyle: TextStyle(color: Colors.black),
                                    labelText: "What's your name?",
                                    labelStyle:
                                        TextStyle(color: Colors.black)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _emailKey,
                              child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter your email";
                              } else if (!EmailValidator.validate(
                                  _emailController.value.text)) {
                                return "Email invalid";
                              } else {
                                return null;
                              }
                            },
                            controller: _emailController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintStyle: TextStyle(color: Colors.black),
                                labelText: "What's your email?",
                                labelStyle: TextStyle(color: Colors.black)),
                              ),
                            ),
                          ),
                          CupertinoButton(
                              color: Colors.black,
                              child: const Text(
                                "Update profile",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                if (_nameKey.currentState!.validate() &
                                    _emailKey.currentState!.validate() &
                                    _nameKey.currentState!.validate()) {
                                  updateData();
                                }
                              }),
                        ],
                      )
                    ],
                  ),
                )),
    );
  }

  updateData() async {
    if (_needUpdateEmail()) {
      await _changeEmail();
    } else if (_needUpdateName()) {
   await _changeName();
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Already updated"),
      ));
    }
  }

  bool _needUpdateEmail() {
    if (_emailController.value.text == _email) {
      return false;
    }
    return true;
  }

  bool _needUpdateName() {
    if (_nameController.value.text == _name) {
      return false;
    }
    return true;
  }

  Future<void> _changeEmail() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "email": _emailController.value.text,
    }, SetOptions(merge: true)).then((value) => {
    Navigator.pop(context,"Updated")

    });
  }

  Future<void> _changeName() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "name": _nameController.value.text,
    }, SetOptions(merge: true)).then((value) => {
              Navigator.pop(context,"Updated")
            });
  }
}
