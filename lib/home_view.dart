import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map/location_serach_view.dart';
import 'package:google_map/utils/constant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    kMarker.addAll(allMarker);
  }

  ///for marker
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

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

  ///Custom marker
  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/Location_marker.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  ///Add marker in list
  final List<Marker> allMarker = [
    Marker(
      markerId: const MarkerId('1'),
      infoWindow: const InfoWindow(title: "1st", snippet: "Faizabad"),
      position: LatLng(AppConstant.lat, AppConstant.lng),
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onTap: () async {
        ///LatLng convert to address
        List<Placemark> placemarks =
            await placemarkFromCoordinates(AppConstant.lat, AppConstant.lng);
        final address = "${placemarks.first.street}";
        print(address);
      },
    ),
    const Marker(
      markerId: MarkerId('2'),
      infoWindow: InfoWindow(title: "2nd", snippet: "Rawalpindi Stadium"),
      position: LatLng(33.65365272452291, 73.07205242134779),
      draggable: true,
    )
  ];

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
      body: GoogleMap(
        zoomControlsEnabled: false,
        markers: Set<Marker>.of(kCurrentLocationMarker.isNotEmpty
            ? kCurrentLocationMarker
            : kMarker),
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          return _kController.complete(controller);
        },
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
          pickCurrentLocationData();
        },
        child: const Icon(Icons.location_searching_outlined),
      ),
    );
  }
}
