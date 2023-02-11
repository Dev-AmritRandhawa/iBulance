

import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'getting_started.dart';

class Decision extends StatefulWidget {
  const Decision({super.key});

  @override
  DecisionState createState() => DecisionState();
}

class DecisionState extends State<Decision> {
  bool result = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Flexible(
                child: Container(
                    height: MediaQuery.of(context).size.height / 6,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(10),
                    child: Image.asset(
                      "assets/iBulance.png",
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                alignment: Alignment.center,
                child: ClipPath(
                  clipper: ClipPathClass(),
                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: Image.asset(
                      "assets/welcome.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 22.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: AnimatedTextKit(
                        isRepeatingAnimation: false,
                        totalRepeatCount: 1,
                        repeatForever: false,
                        animatedTexts: [
                          TypewriterAnimatedText(textAlign: TextAlign.center,
                              'Manage Your \n Emergencies \n Simply.',
                              textStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Arvo"),
                              curve: Curves.easeIn,
                              speed: const Duration(milliseconds: 80)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child:  DelayedDisplay(
    delay: const Duration(milliseconds: 900),
                  child: CupertinoButton(
                    onPressed: () {
                      if (Platform.isIOS) {
                        Navigator.of(context).pushReplacement(CupertinoPageRoute(
                          builder: (context) =>  const GettingStartedScreen(),
                        ));
                      } else if (Platform.isAndroid) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) =>  const GettingStartedScreen(),
                        ));
                      }
                    },
                    color: Colors.black87,
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}

class ClipPathClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 30);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
