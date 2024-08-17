import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../providers/user_profile.dart';

class MapScreen extends StatefulWidget {
  final LatLng destination;

  MapScreen({required this.destination});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  PolylinePoints _polylinePoints = PolylinePoints();
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isNavigating = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  bool _canRequestInstruction = true;
  Timer? _requestTimer;

  @override
  void initState() {
    super.initState();
    _setDestinationMarker();
  }

  void _setDestinationMarker() {
    _markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: widget.destination,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
  }

  void _toggleNavigation() {
    setState(() {
      _isNavigating = !_isNavigating;
    });
    if (_isNavigating) {
      _startNavigation();
    } else {
      _stopNavigation();
    }
  }

  void _startNavigation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _requestTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _canRequestInstruction = true;
    });

    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) async {
      LatLng currentPosition = LatLng(position.latitude, position.longitude);

      // Update camera position
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentPosition,
            zoom: 17.0,
            tilt: 45.0,
            bearing: position.heading,
          ),
        ),
      );

      // Update current location marker
      Marker currentLocationMarker = Marker(
        markerId: MarkerId('current_location'),
        position: currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
        _markers.add(currentLocationMarker);
      });

      // Get polyline from current position to destination
      _getPolyline(currentPosition, widget.destination);

      if (_canRequestInstruction) {
        _canRequestInstruction = false;
        String instruction = await _getNavigationInstruction(currentPosition, widget.destination);
        _speakInstruction(instruction);
      }
    });
  }

  void _stopNavigation() {
    _positionStreamSubscription?.cancel();
    _requestTimer?.cancel();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(widget.destination, 13),
    );
  }

  Future<void> _getPolyline(LatLng source, LatLng destination) async {
    PolylineRequest polylineRequest = PolylineRequest(
      origin: PointLatLng(source.latitude, source.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      mode: TravelMode.driving,
    );

    PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
      request: polylineRequest,
      googleApiKey: 'AIzaSyBJDOhW2JsdKJLFZ61wZTOAlr1nLN81sIg',
    );

    if (result.points.isNotEmpty) {
      setState(() {
        _polylineCoordinates.clear();
        _polylineCoordinates.addAll(result.points.map((point) => LatLng(point.latitude, point.longitude)));
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          points: _polylineCoordinates,
          width: 5,
        ));
      });
    }
  }

  Future<String> _getNavigationInstruction(LatLng start, LatLng end) async {
    final String apiKey = 'AIzaSyBJDOhW2JsdKJLFZ61wZTOAlr1nLN81sIg';
    final String baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

    final String url = '$baseUrl?origin=${start.latitude},${start.longitude}'
        '&destination=${end.latitude},${end.longitude}'
        '&mode=driving'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['status'] == 'OK') {
          final routes = decodedResponse['routes'] as List;
          if (routes.isNotEmpty) {
            final legs = routes[0]['legs'] as List;
            if (legs.isNotEmpty) {
              final steps = legs[0]['steps'] as List;
              if (steps.isNotEmpty) {
                String instruction = steps[0]['html_instructions'];
                instruction = instruction.replaceAll(RegExp(r'<[^>]*>'), '');
                String distance = steps[0]['distance']['text'];
                return '$instruction for $distance';
              }
            }
          }
        }

        return "Unable to get navigation instructions";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> _speakInstruction(String instruction) async {
    final UserProfile userProfile = UserProfile();
    String? local_dialect = await userProfile.getUserDialect();

    print("This is the instructions: $instruction");

    // var url = Uri.parse('http://192.168.43.240:5000/text-to-speech');

    var url = Uri.parse('https://driving-guide.onrender.com/text-to-speech');
    var headers = {
      'Content-Type': 'application/json',
    };
    var body = json.encode({
      'text': instruction,
      'local_dialect': local_dialect,
    });

    var nlpResponse = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (nlpResponse.statusCode == 200) {
      final Directory tempDir = await getTemporaryDirectory();
      final File audioFile = File('${tempDir.path}/output.wav');

      print("Audio file : $audioFile");
      await audioFile.writeAsBytes(nlpResponse.bodyBytes);

      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.play(DeviceFileSource(audioFile.path));
    } else {
      print('Error: ${nlpResponse.statusCode}, ${nlpResponse.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Navigation')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.destination,
          zoom: 13,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleNavigation,
        child: Icon(_isNavigating ? Icons.stop : Icons.navigation),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionStreamSubscription?.cancel();
    _requestTimer?.cancel();
    super.dispose();
  }
}
