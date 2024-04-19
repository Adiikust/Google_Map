import 'dart:async';

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

  final Completer<GoogleMapController> _completer = Completer();
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

  final themeKey = [
    'assets/dark_theme.json',
    'assets/night_theme.json',
    'assets/retro_theme.json',
    'assets/silver_theme.json',
    'assets/aubergine_theme.json',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  _completer.future.then((value) {
                    DefaultAssetBundle.of(context)
                        .loadString(themeKey[0])
                        .then((valueTwo) {
                      value.setMapStyle(valueTwo);
                    });
                  });
                },
                child: const Text('Dark'),
              ),
              PopupMenuItem(
                onTap: () {
                  _completer.future.then((value) {
                    DefaultAssetBundle.of(context)
                        .loadString(themeKey[1])
                        .then((valueTwo) {
                      value.setMapStyle(valueTwo);
                    });
                  });
                },
                child: const Text('Night'),
              ),
              PopupMenuItem(
                onTap: () {
                  _completer.future.then((value) {
                    DefaultAssetBundle.of(context)
                        .loadString(themeKey[2])
                        .then((valueTwo) {
                      value.setMapStyle(valueTwo);
                    });
                  });
                },
                child: const Text('Retro'),
              ),
              PopupMenuItem(
                onTap: () {
                  _completer.future.then((value) {
                    DefaultAssetBundle.of(context)
                        .loadString(themeKey[3])
                        .then((valueTwo) {
                      value.setMapStyle(valueTwo);
                    });
                  });
                },
                child: const Text('Silver'),
              ),
              PopupMenuItem(
                onTap: () {
                  _completer.future.then((value) {
                    DefaultAssetBundle.of(context)
                        .loadString(themeKey[4])
                        .then((valueTwo) {
                      value.setMapStyle(valueTwo);
                    });
                  });
                },
                child: const Text('Aubergine'),
              ),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            markers: Set<Marker>.of(kMarker),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _customInfoWindowController.googleMapController = controller;
              _completer.complete(controller);
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
