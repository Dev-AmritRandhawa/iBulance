import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ibulance/assistants/data.dart';
import 'package:ibulance/home/home_screen.dart';

class SlidingUpData extends StatefulWidget {
 final GoogleMapController refController;

  const SlidingUpData({super.key, required this.refController});


  @override
  State<SlidingUpData> createState() => _SlidingUpDataState();
}

class _SlidingUpDataState extends State<SlidingUpData> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;




  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(
        height: 5,
      ),
      GestureDetector(
        onTap: (){

        },
        child: Container(
          child: Row(
            children: const [
              Icon(Icons.history, color: Colors.black45,),
              Text("")
            ],
          ),
        ),
      )
    ],);
  }

  Future<void> loadData() async {
    await firestore
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
        var data = documentSnapshot.get("last_ride");
        if (data["latitude"]
            .toString()
            .isNotEmpty && data["latitude"] != null && data["longitude"]
            .toString()
            .isNotEmpty && data["longitude"] != null) {
          UserData.destinationLatitude = data["latitude"];
          UserData.destinationLongitude = data["longitude"];

        }
    }
    );
  }
}