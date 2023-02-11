import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../assistants/data.dart';
import '../assistants/map_key.dart';
import '../assistants/origin_destination.dart';
import '../assistants/request_api.dart';
import '../widgets/shimmer_loading.dart';
import 'maps_data_show.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 late GoogleMapController refController;
  bool addressUpdated = false;
  late String updated;
  var yourLocationController = TextEditingController();
  var dropLocationController = TextEditingController();
  bool showModalImageLoad = false;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};

  late String _mapStyle;

  bool markerMovable = true;


  @override
  void initState() {
    permissionCheck();
    rootBundle.loadString('assets/mapStyle.json').then((string) {
      _mapStyle = string;
    });
    super.initState();
  }

  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 18,
  );

  final List<Marker> _markers = <Marker>[

    const Marker(
        markerId: MarkerId('1'),
        position: LatLng(20.42796133580664, 75.885749655962),
        infoWindow: InfoWindow(
          title: 'My Position',
        ))
  ];

  void getUserCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _markers.add(Marker(
        markerId: const MarkerId("2"),
        position: LatLng(position.latitude, position.longitude),
        draggable: markerMovable,
        visible: true,
        infoWindow: const InfoWindow(title: "Hold & Drag"),
        onDragEnd: (value) {
          updateMarkerLocation(value);
        }));

    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    );
    UserData.originLatitude = position.latitude;
    UserData.originLongitude = position.longitude;
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    refController = controller;
    String data = await RequestMethods.searchCoordinateRequests(position);

    setState(() {
      yourLocationController.text = data;
    });
  }

  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: _kGoogle,
          markers: Set<Marker>.of(_markers),
          mapType: MapType.normal,
          scrollGesturesEnabled: true,
          zoomControlsEnabled: true,
          buildingsEnabled: false,

          polylines: polyLineSet,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            controller.setMapStyle(_mapStyle);
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                readOnly: true,
                controller: yourLocationController,
                showCursor: false,
                decoration: InputDecoration(
                    icon: Stack(alignment: Alignment.center, children: const [
                    ]),
                    filled: true,
                    hintText: "Your Location",
                    prefixIcon: const Icon(Icons.fiber_manual_record,
                        color: Colors.green, size: 15),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45),
                      borderSide: BorderSide.none,
                    )),
              ),
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 2.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 25.0,
                              spreadRadius: 25,
                              offset: Offset(
                                -10,
                                -10,
                              ),
                            )
                          ],
                        ),
                        margin: const EdgeInsets.only(top: 25),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: dropLocationController,
                          readOnly: true,
                          onTap: () {
                            setDestinationPage(UserData.originLatitude,
                                UserData.originLongitude);
                          },
                          showCursor: false,
                          decoration: InputDecoration(
                              filled: true,
                              hintText: "Search Destination",
                              prefixIcon: const Icon(Icons.fiber_manual_record,
                                  color: Colors.redAccent, size: 15),
                              fillColor: Colors.white60,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(45),
                                borderSide: BorderSide.none,
                              )),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 40, top: 20, bottom: 10),
                        child: Text(
                          "Drop History",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.grey[300]!,
                        period: const Duration(seconds: 2),
                        child: Column(
                          children: const [
                            ShimmerEffect(),
                            ShimmerEffect(),
                            ShimmerEffect(),
                          ],
                        ),
                      )
                    ]),
              ),
            )
          ],
        )
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[300],
        onPressed: () async {
          if (await permissionCheck()) {
            getUserCurrentLocation();
          }
        },
        child: const Icon(Icons.location_on),
      ),
    );
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
    getUserCurrentLocation();
    return true;
  }

  Future<void> updateMarkerLocation(LatLng position) async {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    );

    UserData.originLatitude = position.latitude;
    UserData.originLongitude = position.longitude;

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
        .latitude},${position.longitude}&key=${MapKey.key}";
    var response = await RequestApi.getRequestUrl(url);
    yourLocationController.text = response["results"][0]["formatted_address"];
  }

  Future<void> setDestinationPage(double latitude, double longitude) async {
    if (Platform.isIOS) {
      if (!mounted) return;
      final result = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) =>
            MapsDataShow(latitude: latitude, longitude: longitude),
      ));
      if (result != null) {
        dropLocationController.text = result;
      }
    }
    if (Platform.isAndroid) {
      if (!mounted) return;
      final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            MapsDataShow(latitude: latitude, longitude: longitude),
      ));
      if (result != null) {
        dropLocationController.text = result;
        var done =
        await OriginDestination(UserData.placeId).getPlaceAddressDetails();
        if (done) {
          directionDataRequest();
        }
      }
    }
  }

  Future<void> directionDataRequest() async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${UserData
          .originLatitude},${UserData.originLongitude}&destination=${UserData
          .destinationLatitude},${UserData.destinationLongitude}&key=${MapKey
          .key}";

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var responsed = jsonDecode(jsonData);
        if (responsed["status"] == "OK") {
          var encodedPoint =
          responsed["routes"][0]["overview_polyline"]["points"];
          responsed["routes"][0]["legs"][0]["distance"]["text"];
          responsed["routes"][0]["legs"][0]["distance"]["value"];
          responsed["routes"][0]["legs"][0]["duration"]["text"];
          responsed["routes"][0]["legs"][0]["duration"]["value"];
          PolylinePoints points = PolylinePoints();
          List<PointLatLng> decodePolyline =
          points.decodePolyline(encodedPoint);
          pLineCoordinates.clear();
          if (decodePolyline.isNotEmpty) {
            for (var pointLatLng in decodePolyline) {
              pLineCoordinates
                  .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
            }
            polyLineSet.clear();
            setState(() {
              Polyline polyline = Polyline(
                  polylineId: const PolylineId("PolylineID"),
                  color: Colors.black,
                  jointType: JointType.round,
                  points: pLineCoordinates,
                  width: 5,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                  geodesic: true);
              polyLineSet.add(polyline);
              markerMovable = false;

            });
    refController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
    southwest: LatLng(
        UserData.originLatitude <= UserData.destinationLatitude
            ? UserData.originLatitude
            : UserData.destinationLatitude,
        UserData.originLongitude <= UserData.destinationLongitude
            ? UserData.originLongitude
            : UserData.destinationLongitude),
    northeast: LatLng(
        UserData.originLatitude <= UserData.destinationLatitude
            ? UserData.destinationLatitude
            : UserData.originLatitude,
        UserData.originLongitude <= UserData.destinationLongitude
            ? UserData.destinationLongitude
            : UserData.originLongitude)),100),);

          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
