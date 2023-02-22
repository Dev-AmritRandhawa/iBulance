import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'data.dart';
import 'map_key.dart';


class OriginDestination {
  final String placeId;


  static bool responseState = false;
  late int distanceValue;
  late int durationValue;
  late String distanceText;
  late String durationText;
  late String encodedPoints;

  OriginDestination(this.placeId);




  Future<bool> getPlaceAddressDetails() async {

    String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${MapKey.key}";
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var decoder = jsonDecode(jsonData);
        if (decoder["status"] == "OK") {
          UserData.destinationLatitude =
          decoder["result"]["geometry"]["location"]["lat"];
          UserData.destinationLongitude =
          decoder["result"]["geometry"]["location"]["lng"];
          return true;
        } else {
          if (decoder == "failed") {
            return false;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }
}