
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibulance/model/profile_creation.dart';

import '../home/home_screen.dart';

class UserStateAuthentication extends StatefulWidget {
  const UserStateAuthentication({super.key});


  @override
  UserStateAuthenticationState createState() =>
      UserStateAuthenticationState();
}

class UserStateAuthenticationState extends State<UserStateAuthentication> {
  @override
  void initState() {
    _authenticator();
    super.initState();
  }

  final FirebaseFirestore _server = FirebaseFirestore.instance;

  @override
  void dispose() {
    _server.terminate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              child: Platform.isIOS
                  ? const CupertinoActivityIndicator()
                  : const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.black)),
            ),
          )
        ],
      ),
    );
  }


  Future<void> _authenticator() async {
    await _server
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .get()
        .then((value) {
      if (value.exists) {

        if (Platform.isIOS) {
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (context) => const HomeScreen(),
          ));
        }
        if (Platform.isAndroid) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
        }
      } else {
        _createNewUser();
      }
    });
  }

  Future<void> _createNewUser() async {
    await FirebaseFirestore.instance.collection("Users").doc(
        FirebaseAuth.instance.currentUser!.phoneNumber).set({

      // Needs to add more details according to clients needs
      "profileComplete": true,
      "uid": FirebaseAuth.instance.currentUser!.uid
    }, SetOptions(merge: true)).then((value) =>
    {
      if (Platform.isIOS){
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) =>  const ProfileCreation(),
        ))
      }
      else
      {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>  const ProfileCreation(),
        ))
      }
    });
  }
}

