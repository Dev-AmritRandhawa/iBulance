import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ibulance/screens/phone_otp.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/page_view_data.dart';
import '../model/slide_item.dart';
import '../widgets/slide_dots.dart';

class GettingStartedScreen extends StatefulWidget {
  const GettingStartedScreen({super.key});

  @override
  GettingStartedScreenState createState() => GettingStartedScreenState();
}

class GettingStartedScreenState extends State<GettingStartedScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
            child: Stack (
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height/5,
                  width: MediaQuery.of(context).size.width/2.5,
                  margin: const EdgeInsets.only(top: 20),
                  child: Center(child: Image.asset("assets/iBulance.png")),
                ),
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: slideList.length,
                  itemBuilder: (ctx, i) => SlideItem(i),
                ),
              ],
            ),
          ),
          bottomSheet: _currentPage != slideList.length - 1
              ? Container(
            margin: const EdgeInsets.all(10),
                decoration:  BoxDecoration(
                    borderRadius: BorderRadius.circular(10),color: Colors.redAccent,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (int i = 0; i < slideList.length; i++)
                          if (i == _currentPage)
                             const SlideDots(true)
                          else
                             const SlideDots(false)
                      ],
                    ),
                    TextButton(
                        onPressed: () {
                          _pageController.animateToPage(_currentPage + 1,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeIn);
                        },
                        child: Row(
                          children: const [
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            )
                          ],
                        )),
                  ],
                ),
              )
              : MaterialButton(
                  onPressed: () async {
                   if( await permissionCheck()){
                     userStateSave();
                     if (Platform.isIOS) {
                       Navigator.of(context).pushReplacement(CupertinoPageRoute(
                         builder: (context) =>  const MobileAuthentication(),
                       ));
                     } else if (Platform.isAndroid) {
                       Navigator.of(context).pushReplacement(MaterialPageRoute(
                         builder: (context) =>  const MobileAuthentication(),
                       ));
                     }
                   }
                   else{
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location Disabled")));
                   }
                    },
                  height: Platform.isIOS ? 70.0 : 50,
                  minWidth: MediaQuery.of(context).size.width,
                  color: Colors.redAccent,
                  child: const Text(
                    "Allow Permission",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )),
    );
  }
}
Future<bool> permissionCheck() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    Geolocator.openAppSettings();
    return false;
  }
  return true;
}

void userStateSave() async {
  final data = await SharedPreferences.getInstance();
  data.setInt("userState", 1);
}
