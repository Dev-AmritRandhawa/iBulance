

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class ProfileCreation extends StatefulWidget {
  const ProfileCreation({Key? key}) : super(key: key);

  @override
  State<ProfileCreation> createState() => _ProfileCreationState();
}

class _ProfileCreationState extends State<ProfileCreation> {

final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
mainAxisAlignment: MainAxisAlignment.center,
          children: [TextField(

            controller: nameController,
            showCursor: false,
            decoration: InputDecoration(
                icon: Stack(alignment: Alignment.center, children: const [
                ]),
                filled: true,
                hintText: "Your Name",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(45),
                  borderSide: BorderSide.none,
                )),
          ),const SizedBox(height: 15),
            TextField(

              controller: nameController,
              showCursor: false,
              decoration: InputDecoration(
                  icon: Stack(alignment: Alignment.center, children: const [
                  ]),
                  filled: true,
                  hintText: "What's your email",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45),
                    borderSide: BorderSide.none,
                  )),
            ),
            Center(
              child: CupertinoButton(
                color: Colors.redAccent,
                onPressed: () {
                  if (Platform.isIOS) {
                    Navigator.of(context).pushReplacement(CupertinoPageRoute(
                      builder: (context) =>  const HomeScreen(),
                    ));
                  }
                  if (Platform.isAndroid) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>  const HomeScreen(),
                    ));
                  }
                },
                child: const Text("Create Profile",style: TextStyle(color: Colors.white),),
              ),
            ),

          ],
        ),
      ));
  }




}
