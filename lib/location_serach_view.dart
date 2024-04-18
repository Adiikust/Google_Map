import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_map/utils/constant.dart';
import 'package:http/http.dart' as http;

class LocationSearchView extends StatefulWidget {
  const LocationSearchView({super.key});

  @override
  State<LocationSearchView> createState() => _LocationSearchViewState();
}

class _LocationSearchViewState extends State<LocationSearchView> {
  ///Text field controller
  final TextEditingController _controller = TextEditingController();

  ///Store Places List
  List<dynamic> responseList = [];

  ///Token (use Random number)
  final String tokenForSession = "37456";

  ///Suggestion function
  Future<void> suggestion(String inputText) async {
    String googlePlacesApiKey = 'AIzaSyCvRYY_cKPzBLI1QqRgCOhP-BCnWXesEXg';
    String groundURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$groundURL?input=$inputText&key=$googlePlacesApiKey&sessiontoken=$tokenForSession';

    var response = await http.get(Uri.parse(request));
    var responseResult = response.body.toString();
    print("Response Body : $responseResult");

    if (response.statusCode == 200) {
      setState(() {
        responseList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('please try again later');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      suggestion(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
          onChanged: (String query) {},
        ),
      ),
      body: ListView.builder(
        itemCount: responseList.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () async {
              ///LatLng address to LatLong

              List<Location> location =
                  await locationFromAddress(responseList[index]['description']);
              setState(() {
                AppConstant.lat = location.first.latitude;
                AppConstant.lng = location.first.longitude;
              });
              final latLng =
                  "${location.first.latitude} ,${location.first.longitude}";
              print(latLng);
            },
            title: Text(responseList[index]['description']),
          );
        },
      ),
    );
  }
}
