
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'map_key.dart';

class RequestApi {
 static late bool responseState;

  static Future<dynamic> getRequestUrl(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var decoder = jsonDecode(jsonData);
        responseState = true;
        return decoder;
      } else {
        responseState = false;

      }

    } catch (e) {
      responseState = false;
    }
  }
}
class RequestMethods {
  static Future<String> searchCoordinateRequests(Position position) async {
     String placeAddress = "";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${MapKey.key}";
    var response = await RequestApi.getRequestUrl(url);
    if (RequestApi.responseState) {
      placeAddress = response["results"][0]["formatted_address"];

    return placeAddress;
    }
    return "Couldn't Locate";
  }
}
