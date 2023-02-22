import 'package:flutter/material.dart';
import '../assistants/data.dart';
import '../assistants/map_key.dart';
import '../assistants/place_prediction.dart';
import '../assistants/request_api.dart';

class MapsDataShow extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapsDataShow(
      {super.key, required this.latitude, required this.longitude});

  @override
  State<MapsDataShow> createState() => _MapsDataShowState();
}

class _MapsDataShowState extends State<MapsDataShow> {
  List<PlacePrediction> listData = [];

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [

              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: TextButton(onPressed: () {
                    Navigator.pop(context);
                  }, child: const Text("Close",style: TextStyle(fontSize: 18),)),
                )
              ]),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(

                  controller: controller,
                  onChanged: (value) {
                    _placeApiRequest(value, MapKey.key);
                  },
                  showCursor: false,

                  decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                          onTap: () {
                            controller.clear();
                          },
                          child:
                          const Icon(Icons.close, color: Colors.black54)),
                      filled: true,
                      hintText: "Search Destination",
                      prefixIcon: const Icon(Icons.fiber_manual_record,
                          color: Colors.green, size: 20),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),

              (listData.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView.separated(
                        itemCount: listData.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemBuilder: (BuildContext context, int index) {
                          return PredictionTile(placesData: listData[index]);
                        },
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                      ),
                    )
                  :  Container()
            ],
          ),
        ));
  }

  Future<void> _placeApiRequest(String userkeyboardData, String key) async {
    UserData.originLatitude = widget.latitude;
    UserData.originLongitude = widget.longitude;
    if (userkeyboardData.length > 1) {
      String autoComplete =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$userkeyboardData&location=${widget.latitude}%2C${widget.longitude}&radius=50&key=$key";

      var response = await RequestApi.getRequestUrl(autoComplete);
      if (response["status"] == "OK") {
        var prediction = response["predictions"];
        var placeList = (prediction as List)
            .map((e) => PlacePrediction.fromJson(e))
            .toList();
        setState(() {
          if (mounted) {
            listData = placeList;
          }
        });
      } else {}
    }
  }
}

class PredictionTile extends StatefulWidget {
  final PlacePrediction placesData;

  const PredictionTile({Key? key, required this.placesData}) : super(key: key);

  @override
  State<PredictionTile> createState() => _PredictionTileState();
}

class _PredictionTileState extends State<PredictionTile> {
  bool responseState = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final data =
            "${widget.placesData.mainText} ${widget.placesData.secondaryText}";
        UserData.placeId = widget.placesData.placeId;
        Navigator.pop(context, data);
      },
      child: ListBody(
        children: [
          Text(
            widget.placesData.mainText,
            style: const TextStyle(
              fontFamily: "Raleway",
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            softWrap: false,
            maxLines: 3,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            widget.placesData.secondaryText,
            softWrap: false,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }
}
