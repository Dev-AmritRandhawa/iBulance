

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';

import '../../model/firebase_services.dart';
import '../../model/profile_edit.dart';
import '../../widgets/indicator.dart';
import '../account_settings.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {


  final User? _auth = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  String _name = "";
  String _email = "";
  String _photoURL = "";
  String _age = "";

  Future<void> _display() async {
    FirebaseFirestore server = FirebaseFirestore.instance;
    await server
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        _name = documentSnapshot.get("name");
        _age = documentSnapshot.get("age");
        _email = documentSnapshot.get("email");
        _photoURL = documentSnapshot.get("photoURL");
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
  FutureOr onGoBack() {
    setState(() {
      _display();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated"),));
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return _loading
                ? Shimmer.fromColors(
              highlightColor: Colors.black,
              baseColor: Colors.grey.shade100,
              child: Center(child: Indicator.show(context)))
                : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        Center(
                          child: CircleAvatar(
                            backgroundImage: _photoURL.isEmpty
                                ? null
                                : NetworkImage(_photoURL),
                            backgroundColor: Colors.grey.shade100,
                            maxRadius: MediaQuery.of(context).size.width / 5,
                            child: _photoURL.isEmpty
                                ? Image.asset("images/profile.png")
                                : null,
                          ),
                        ),

                        Center(child: Text(_name,style: const TextStyle(fontSize: 18,color: Colors.black87,fontFamily: "Ubuntu"),)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Center(child: Text("Age",style: TextStyle(),)),
                            const SizedBox(
                              width: 5,
                            ),
                            Center(child: Text(_age,style: const TextStyle(fontSize: 18,color: Colors.black87,fontFamily: "Ubuntu"),)),

                          ],
                        ),
                        Center(
                          child: TextButton(
                              onPressed: () async {
                                if (Platform.isIOS) {
                                 Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) =>  const ProfileEdit(),
                                  )
                                 ).then((value) => onGoBack());

                                } if (Platform.isAndroid) {
                                 Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const ProfileEdit(),
                                  )
                                  ).then((value) => onGoBack());
                                }
                              },
                              child: const Text("Edit profile")),
                        ),
                        _layout("Email", _email),
                        _layout("Number", _auth!.phoneNumber.toString()),
                        GestureDetector(
                          onTap: () {
                            if (Platform.isIOS) {
                              Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) => const AccountSettings(),
                              ));
                            }
                            if (Platform.isAndroid) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const AccountSettings(),
                              ));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Privacy & settings"),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: CupertinoButton(
                              color: Colors.blue,
                              child: const Text("Logout"),
                              onPressed: () {
                                FirebaseServices services = FirebaseServices();
                                services.signOut(context);
                              }),
                        ),
                      ],
                    );
          },
        ),
      ),
    );
  }

  Widget _layout(String title, String data) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Text(
                data,
                style: const TextStyle(fontFamily: "Ubuntu", fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
