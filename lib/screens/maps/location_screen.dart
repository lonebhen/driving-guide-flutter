import 'package:driving_guide/screens/maps/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const kGoogleApiKey = "AIzaSyBJDOhW2JsdKJLFZ61wZTOAlr1nLN81sIg";

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _placesList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Destination'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Where do you want to go?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  autoCompleteSearch(value);
                } else {
                  setState(() {
                    _placesList = [];
                  });
                }
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _placesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_placesList[index]['description']),
                    onTap: () {
                      _getPlaceDetails(_placesList[index]['place_id']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void autoCompleteSearch(String input) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$kGoogleApiKey&components=country:gh';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _placesList = json.decode(response.body)['predictions'];
      });
    }
  }

  void _getPlaceDetails(String placeId) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseURL?place_id=$placeId&key=$kGoogleApiKey';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      var result = json.decode(response.body)['result'];
      double lat = result['geometry']['location']['lat'];
      double lng = result['geometry']['location']['lng'];

      LatLng _destinationLocation = LatLng(lat, lng);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            destination: _destinationLocation,
          ),
        ),
      );
    }
  }
}