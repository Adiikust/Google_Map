import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map/location_serach_view.dart';
import 'package:google_map/utils/constant.dart';
import 'package:google_map/utils/polyline_response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();

    ///add marker in list
    //kMarker.addAll(allMarker);
  }

  String totalDistance = "";
  String totalTime = "";

  ///polyline
  PolylineResponse polylineResponse = PolylineResponse();

  Set<Polyline> polylinePoints = {};

  ///Google map controller
  final Completer<GoogleMapController> _kController =
      Completer<GoogleMapController>();

  ///Camera position
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(AppConstant.lat, AppConstant.lng),
    zoom: 14.4746,
  );

  ///Create empty marker list
  final List<Marker> kMarker = [];
  final List<Marker> kCurrentLocationMarker = [];

  ///Add marker in list
  // final List<Marker> allMarker = [
  //   Marker(
  //     markerId: const MarkerId('1'),
  //     infoWindow: const InfoWindow(title: "1st", snippet: "Faizabad"),
  //     position: LatLng(AppConstant.lat, AppConstant.lng),
  //     draggable: true,
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //     onTap: () async {
  //       ///LatLng convert to address
  //       List<Placemark> placemarks =
  //           await placemarkFromCoordinates(AppConstant.lat, AppConstant.lng);
  //       final address = "${placemarks.first.street}";
  //       print(address);
  //     },
  //   ),
  //   const Marker(
  //     markerId: MarkerId('2'),
  //     infoWindow: InfoWindow(title: "2nd", snippet: "Rawalpindi Stadium"),
  //     position: LatLng(33.65365272452291, 73.07205242134779),
  //     draggable: true,
  //   )
  // ];

  ///Get Current Location
  Future<Position> getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Current location permission error: $error ");
    });
    return Geolocator.getCurrentPosition();
  }

  ///Set Camera position, Marker and latlng convert to address
  pickCurrentLocationData() {
    getCurrentLocation().then(
      (value) async {
        print("My location LatLng");
        print("lat ${value.latitude}");
        print("lng ${value.longitude}");

        ///LatLng convert to address
        List<Placemark> placemarks =
            await placemarkFromCoordinates(value.latitude, value.longitude);
        final currentLocation =
            "${placemarks.first.country} ${placemarks.first.subAdministrativeArea} ${placemarks.first.name}";
        print(currentLocation);

        kCurrentLocationMarker.add(Marker(
          markerId: const MarkerId('3'),
          infoWindow: InfoWindow(title: currentLocation),
          draggable: true,
          position: LatLng(value.latitude, value.longitude),
        ));
        final GoogleMapController controller = await _kController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(value.latitude, value.longitude), zoom: 14),
          ),
        );
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocationSearchView()),
                );
              },
              icon: const Icon(Icons.search)),
          const SizedBox(width: 10)
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            polylines: polylinePoints,
            zoomControlsEnabled: false,
            markers: Set<Marker>.of(kCurrentLocationMarker.isNotEmpty
                ? kCurrentLocationMarker
                : kMarker),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _kController.complete(controller);
            },
          ),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Total Distance: " + totalDistance),
                Text("Total Time: " + totalTime),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ///Go to the camera position
          //final GoogleMapController controller = await _kController.future;
          // await controller.animateCamera(CameraUpdate.newCameraPosition(
          //   const CameraPosition(
          //       bearing: 192.8334901395799,
          //       target: LatLng(33.569651282036446, 73.0184964224423),
          //       tilt: 59.440717697143555,
          //       zoom: 19.151926040649414),
          // ));
          ///Get current location
          //pickCurrentLocationData();
          ///draw polyline
          drawPolyline();
        },
        child: const Icon(Icons.location_searching_outlined),
      ),
    );
  }

  void drawPolyline() async {
    String apiKey = "AIzaSyCvRYY_cKPzBLI1QqRgCOhP-BCnWXesEXg";

    String originLat = "33.66062976080691";
    String originLng = "73.08286701276366";
    String destinationLat = "33.65365272452291";
    String destinationLng = "73.07205242134779";

    var response = await http.post(Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?key=$apiKey&units=metric&origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&mode=driving"));

    print(response.body);

    polylineResponse = PolylineResponse.fromJson(jsonDecode(response.body));

    totalDistance = polylineResponse.routes![0].legs![0].distance!.text!;
    totalTime = polylineResponse.routes![0].legs![0].duration!.text!;

    kMarker.clear();

    // Add the origin marker
    kMarker.add(Marker(
      markerId: const MarkerId('origin'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: LatLng(AppConstant.lat, AppConstant.lng),
      infoWindow: const InfoWindow(title: 'Origin'),
    ));

    // Add the destination marker
    kMarker.add(const Marker(
      markerId: MarkerId('destination'),
      position: LatLng(33.65365272452291, 73.07205242134779),
      infoWindow: InfoWindow(title: 'Destination'),
    ));

    polylinePoints.clear();

    for (int i = 0;
        i < polylineResponse.routes![0].legs![0].steps!.length;
        i++) {
      polylinePoints.add(Polyline(
        polylineId: PolylineId(
            polylineResponse.routes![0].legs![0].steps![i].polyline!.points!),
        points: [
          LatLng(
              polylineResponse
                  .routes![0].legs![0].steps![i].startLocation!.lat!,
              polylineResponse
                  .routes![0].legs![0].steps![i].startLocation!.lng!),
          LatLng(
              polylineResponse.routes![0].legs![0].steps![i].endLocation!.lat!,
              polylineResponse.routes![0].legs![0].steps![i].endLocation!.lng!),
        ],
        width: 5,
        color: Colors.red,
      ));
    }

    setState(() {});
  }
}
