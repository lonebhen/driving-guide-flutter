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
import 'package:flutter_tts/flutter_tts.dart';

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
  FlutterTts _flutterTts = FlutterTts();
  bool _isNavigating = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _requestTimer;

  bool _canRequestInstruction = true;

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

    _requestTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
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
        markerId: const MarkerId('current_location'),
        position: currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
        _markers.add(currentLocationMarker);
      });

      // Get polyline from current position to destination
      _getPolyline(currentPosition, widget.destination);

      // Check distance to destination
      double distanceToDestination = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        widget.destination.latitude,
        widget.destination.longitude,
      );

      if (distanceToDestination <= 10) {
        _showArrivalDialog();
      }

      if (_canRequestInstruction) {
        _canRequestInstruction = false;
        String instruction = await _getNavigationInstruction(currentPosition, widget.destination);
        await _playInstruction(instruction);
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
          color: Colors.blue.shade900,
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

  Future<void> _playInstruction(String instruction) async {
    final UserProfile userProfile = UserProfile();
    String? localDialect = await userProfile.getUserDialect();

    // Split instruction into navigational part and landmark part
    List<String> parts = _splitInstruction(instruction);

    // Play navigational part first
    var navigationalPart = parts[0];
    var url = Uri.parse('https://driving-guide.onrender.com/text-to-speech');
    var headers = {'Content-Type': 'application/json'};
    var body = json.encode({
      'text': navigationalPart,
      'local_dialect': localDialect,
    });

    var nlpResponse = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (nlpResponse.statusCode == 200) {
      final Directory tempDir = await getTemporaryDirectory();
      final File audioFile = File('${tempDir.path}/output.wav');
      await audioFile.writeAsBytes(nlpResponse.bodyBytes);
      await _audioPlayer.play(DeviceFileSource(audioFile.path));

      await _audioPlayer.onPlayerComplete.first;

      // Play landmark part after navigational part
      var landmarkPart = parts.length > 1 ? parts[1] : '';
      if (landmarkPart.isNotEmpty) {
        await Future.delayed(Duration(seconds: 1)); // Delay to ensure navigational part is finished
        await _playLandmark(landmarkPart);
      }
    } else {
      print('Error: ${nlpResponse.statusCode}, ${nlpResponse.body}');
    }
  }

  Future<void> _playLandmark(String landmark) async {
    // Directly play the landmark part
    print('Landmark: $landmark');
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.speak(landmark);

  }

  List<String> _splitInstruction(String instruction) {
    // Split the instruction based on prepositions like 'onto'
    RegExp exp = RegExp(r'(onto|to|on|into|at)\s+(.*)', caseSensitive: false);
    Match? match = exp.firstMatch(instruction);

    if (match != null) {
      String navigationalPart = instruction.substring(0, match.start).trim();
      String landmarkPart = match.group(2) ?? '';
      return [navigationalPart, landmarkPart];
    }
    return [instruction];
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You Have Arrived'),
          content: Text('You are within 10 meters of your destination.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/home'); // Navigate to home screen
              },
              child: Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionStreamSubscription?.cancel();
    _requestTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
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
}
