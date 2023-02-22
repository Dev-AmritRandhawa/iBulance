import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../assistants/data.dart';
import '../../assistants/map_key.dart';
import '../../assistants/origin_destination.dart';
import '../../assistants/request_api.dart';
import '../../home/maps_data_show.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    rootBundle.loadString('assets/mapStyle.json').then((string) {
      _mapStyle = string;
    });
    getUserCurrentLocation();
    addCustomIcon();
    super.initState();
  }

  bool loadDestinationData = false;
  bool calculating = false;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};
  String distanceText = "";
  int distanceValue = 0;
  String durationText = "";
  int durationValue = 0;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationLocationIcon = BitmapDescriptor.defaultMarker;
  final List<Marker> markers = <Marker>[];
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 0.0;
  bool addressUpdated = false;

  late GoogleMapController refController;

  late String updated;
  var yourLocationController = TextEditingController();
  var dropLocationController = TextEditingController();
  bool showModalImageLoad = false;
  late String _mapStyle;

  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(20.593683, 78.962883),
    zoom: 18,
  );

  @override
  Widget build(BuildContext context) {

    _panelHeightOpen = MediaQuery
        .of(context)
        .size
        .height * .60;
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        GoogleMap(
          initialCameraPosition: _kGoogle,
          markers: Set<Marker>.of(markers),
          mapType: MapType.normal,
          scrollGesturesEnabled: true,
          zoomControlsEnabled: false,
          buildingsEnabled: false,
          tiltGesturesEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          polylines: polyLineSet,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            controller.setMapStyle(_mapStyle);
          },
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
                child: TextField(
                  readOnly: true,
                  controller: yourLocationController,
                  showCursor: false,
                  decoration: InputDecoration(
                      filled: true,
                      hintText: "Your Location",
                      prefixIcon: const Icon(Icons.fiber_manual_record,
                          color: Colors.green, size: 20),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: TextField(
                  controller: dropLocationController,
                  readOnly: true,
                  onTap: () {
                    setDestinationPage(
                        UserData.originLatitude, UserData.originLongitude);
                  },
                  showCursor: false,
                  decoration: InputDecoration(
                      filled: true,
                      hintText: "Search Destination",
                      prefixIcon: const Icon(Icons.fiber_manual_record,
                          color: Colors.redAccent, size: 20),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 20.0,
          bottom: 50,
          child: FloatingActionButton(
            onPressed: () {
              getUserCurrentLocation();
            },
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.gps_fixed,
              color: Colors.blueGrey,
            ),
          ),
        ),
        SlidingUpPanel(
          controller: pc,
          defaultPanelState: PanelState.CLOSED,
          maxHeight: _panelHeightOpen,
          minHeight: _panelHeightClosed,
          parallaxEnabled: true,
          parallaxOffset: .5,
          panelBuilder: (sc) => _panel(sc),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
          onPanelSlide: (data) {
            _panelHeightClosed = MediaQuery.of(context).size.height / 3;
          },
        ),
      ],
    );
  }
  void getUserCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 18,
    );
    UserData.originLatitude = position.latitude;
    UserData.originLongitude = position.longitude;
    final GoogleMapController controller = await _controller.future;
    refController = controller;

    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String data = await RequestMethods.searchCoordinateRequests(position);

    setState(() {
      yourLocationController.text = data;
    });
  }

  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );
  PanelController pc = PanelController();

  Future<void> updateMarkerLocation(LatLng position) async {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 18,
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
          pc.open();
          calculationRoute();
        }
      }
    }
  }

  Future<void> addCustomIcon() async {
    await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/placeholder.png")
        .then(
          (icon) {
        currentLocationIcon = icon;
      },
    );
    await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/placeholder.png")
        .then(
          (icon) {
        destinationLocationIcon = icon;
      },
    );
    setState(() {});
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
            physics: const BouncingScrollPhysics(),
            controller: sc,
            children: <Widget>[
              const SizedBox(
                height: 12.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.all(
                            Radius.circular(12.0))),
                  ),
                ],
              ),
              const SizedBox(
                height: 18.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    "Explore Offers",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 24.0,
                    ),
                  ),

                ],
              ),
              const SizedBox(
                height: 36.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _button("Popular", Icons.favorite, Colors.blue),
                  _button("Food", Icons.restaurant, Colors.red),
                  _button("Events", Icons.event, Colors.amber),
                  _button("More", Icons.more_horiz, Colors.green),
                ],
              ),
              const SizedBox(
                height: 36.0,
              ),
              Container(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("Images",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Image.network(
                          "https://images.fineartamerica.com/images-medium-large-5/new-pittsburgh-emmanuel-panagiotakis.jpg",
                          height: 120.0,
                          width: (MediaQuery
                              .of(context)
                              .size
                              .width - 48) / 2 - 2,
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          "https://cdn.pixabay.com/photo/2016/08/11/23/48/pnc-park-1587285_1280.jpg",
                          width: (MediaQuery
                              .of(context)
                              .size
                              .width - 48) / 2 - 2,
                          height: 120.0,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 36.0,
              ),
              Container(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text("About",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      """Pittsburgh is a city in the state of Pennsylvania in the United States, and is the county seat of Allegheny County. A population of about 302,407 (2018) residents live within the city limits, making it the 66th-largest city in the U.S. The metropolitan population of 2,324,743 is the largest in both the Ohio Valley and Appalachia, the second-largest in Pennsylvania (behind Philadelphia), and the 27th-largest in the U.S.\n\nPittsburgh is located in the southwest of the state, at the confluence of the Allegheny, Monongahela, and Ohio rivers. Pittsburgh is known both as "the Steel City" for its more than 300 steel-related businesses and as the "City of Bridges" for its 446 bridges. The city features 30 skyscrapers, two inclined railways, a pre-revolutionary fortification and the Point State Park at the confluence of the rivers. The city developed as a vital link of the Atlantic coast and Midwest, as the mineral-rich Allegheny Mountains made the area coveted by the French and British empires, Virginians, Whiskey Rebels, and Civil War raiders.\n\nAside from steel, Pittsburgh has led in manufacturing of aluminum, glass, shipbuilding, petroleum, foods, sports, transportation, computing, autos, and electronics. For part of the 20th century, Pittsburgh was behind only New York City and Chicago in corporate headquarters employment; it had the most U.S. stockholders per capita. Deindustrialization in the 1970s and 80s laid off area blue-collar workers as steel and other heavy industries declined, and thousands of downtown white-collar workers also lost jobs when several Pittsburgh-based companies moved out. The population dropped from a peak of 675,000 in 1950 to 370,000 in 1990. However, this rich industrial history left the area with renowned museums, medical centers, parks, research centers, and a diverse cultural district.\n\nAfter the deindustrialization of the mid-20th century, Pittsburgh has transformed into a hub for the health care, education, and technology industries. Pittsburgh is a leader in the health care sector as the home to large medical providers such as University of Pittsburgh Medical Center (UPMC). The area is home to 68 colleges and universities, including research and development leaders Carnegie Mellon University and the University of Pittsburgh. Google, Apple Inc., Bosch, Facebook, Uber, Nokia, Autodesk, Amazon, Microsoft and IBM are among 1,600 technology firms generating \$20.7 billion in annual Pittsburgh payrolls. The area has served as the long-time federal agency headquarters for cyber defense, software engineering, robotics, energy research and the nuclear navy. The nation's eighth-largest bank, eight Fortune 500 companies, and six of the top 300 U.S. law firms make their global headquarters in the area, while RAND Corporation (RAND), BNY Mellon, Nova, FedEx, Bayer, and the National Institute for Occupational Safety and Health (NIOSH) have regional bases that helped Pittsburgh become the sixth-best area for U.S. job growth.
              """,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              )
            ]));
  }

  Widget _button(String label, IconData icon, Color color) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration:
          BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 8.0,
            )
          ]),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 12.0,
        ),
        Text(label),
      ],
    );

  }

  void calculationRoute() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _panelHeightClosed = MediaQuery.of(context).size.height/3.5;
      });
    });
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
          distanceText = responsed["routes"][0]["legs"][0]["distance"]["text"];

          distanceValue =
          responsed["routes"][0]["legs"][0]["distance"]["value"];
          durationText = responsed["routes"][0]["legs"][0]["duration"]["text"];

          durationValue =
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
            markers.add(Marker(
              icon: destinationLocationIcon,
              markerId: const MarkerId("2"),
              position: LatLng(
                  UserData.destinationLatitude, UserData.destinationLongitude),
              visible: true,
              infoWindow: const InfoWindow(title: "Destination"),
            ));
            setState(() {
              loadDestinationData = true;
              Polyline polyline = Polyline(

                  polylineId: const PolylineId("PolylineID"),
                  color: Colors.black87,
                  jointType: JointType.bevel,
                  points: pLineCoordinates,
                  width: 3,
                  startCap: Cap.squareCap,
                  endCap: Cap.squareCap,
                  geodesic: true);
              polyLineSet.add(polyline);
            });
            refController.animateCamera(
              CameraUpdate.newLatLngBounds(
                  LatLngBounds(
                      southwest: LatLng(
                          UserData.originLatitude <=
                              UserData.destinationLatitude
                              ? UserData.originLatitude
                              : UserData.destinationLatitude,
                          UserData.originLongitude <=
                              UserData.destinationLongitude
                              ? UserData.originLongitude
                              : UserData.destinationLongitude),
                      northeast: LatLng(
                          UserData.originLatitude <=
                              UserData.destinationLatitude
                              ? UserData.destinationLatitude
                              : UserData.originLatitude,
                          UserData.originLongitude <=
                              UserData.destinationLongitude
                              ? UserData.destinationLongitude
                              : UserData.originLongitude)),
                  100),
            );
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
