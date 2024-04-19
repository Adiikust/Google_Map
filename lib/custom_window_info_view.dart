import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_map/utils/constant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomWindowInfoView extends StatefulWidget {
  const CustomWindowInfoView({super.key});

  @override
  State<CustomWindowInfoView> createState() => _CustomWindowInfoViewState();
}

class _CustomWindowInfoViewState extends State<CustomWindowInfoView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customInfo();
  }

  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  final List<Marker> kMarker = [];

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(AppConstant.lat, AppConstant.lng),
    zoom: 14.4746,
  );

  customInfo() {
    kMarker.add(Marker(
      markerId: const MarkerId('1'),
      position: LatLng(AppConstant.lat, AppConstant.lng),
      draggable: true,
      onTap: () async {
        ///LatLng convert to address
        List<Placemark> placemarks =
            await placemarkFromCoordinates(AppConstant.lat, AppConstant.lng);
        final address = "${placemarks.first.street}";
        _customInfoWindowController.addInfoWindow!(
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_circle,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 8.0),
                        Text(address)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          LatLng(AppConstant.lat, AppConstant.lng),
        );
        setState(() {});
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Map")),
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            markers: Set<Marker>.of(kMarker),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _customInfoWindowController.googleMapController = controller;
            },
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 75,
            width: 150,
            offset: 50,
          ),
        ],
      ),
    );
  }
}
