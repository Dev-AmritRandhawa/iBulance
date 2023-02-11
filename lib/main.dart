import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibulance/screens/decision.dart';
import 'package:ibulance/screens/phone_otp.dart';
import 'package:ibulance/widgets/indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Future.delayed(const Duration(seconds: 2), () {
              _checkUser();
            }));
    return Scaffold(
      body: Center(child: Indicator.show(context)),
    ); // widget tree
  }

  Future<bool> userState() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser != null) {
        return true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      return false;
    }
    return false;
  }

  Future<void> _checkUser() async {
    if (await userState()) {
      if (mounted) {
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
      }
    } else {
      _newUser();
    }
  }

  _newUser() async {
    if (await userStateSave()) {
      if (Platform.isIOS) {
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => const Decision(),
        ));
      }
      if (Platform.isAndroid) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const Decision(),
        ));
      }
    } else {
      _welcomePage();
    }
  }

  _welcomePage() {
    if (Platform.isIOS) {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (context) => const MobileAuthentication(),
      ));
    }
    if (Platform.isAndroid) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MobileAuthentication(),
      ));
    }
  }

  Future<bool> userStateSave() async {
    final value = await SharedPreferences.getInstance();
    if (value.getInt("userState") != 1) {
      return true;
    }
    return false;
  }
}
