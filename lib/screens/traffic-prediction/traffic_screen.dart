import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import '../../providers/traffic_api_provider.dart';

class TrafficScreen extends StatefulWidget {
  @override
  _TrafficScreenState createState() => _TrafficScreenState();
}

class _TrafficScreenState extends State<TrafficScreen> {
  File? _image;
  final picker = ImagePicker();
  final FlutterTts flutterTts = FlutterTts();
  AudioPlayer audioPlayer = AudioPlayer();
  final TrafficApiProvider apiProvider = TrafficApiProvider();
  bool _isLoading = false;

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _uploadImage(_image!);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage(File image) async {
    setState(() {
      _isLoading = true;
    });

    final response = await apiProvider.uploadImage(image);

    setState(() {
      _isLoading = false;
    });

    if (response != null) {
      _playAudio(response);
    } else {
      print('Failed to get audio response');
    }
  }

  // Future<void> _playAudio(String audioUrl) async {
  //   try {
  //     await flutterTts.stop();
  //     await flutterTts.setLanguage("en-US");
  //     await flutterTts.setSpeechRate(1.0);
  //     await flutterTts.speak(Uri.play(audioUrl)); // check here again, it was play
  //   } catch (e) {
  //     print('Failed to play audio: $e');
  //   }
  // }

  Future<void> _playAudio(String audioUrl) async {
      await audioPlayer.stop(); // Stop any currently playing audio
      await audioPlayer.play(audioUrl as Source); // Play the audio from URL

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Upload Traffic Sign Picture'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image == null)
              Text('No image selected.')
            else
              Flexible(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.file(_image!),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            if (_image != null)
              ElevatedButton.icon(
                icon: Icon(Icons.volume_up),
                label: Text('Hear Prediction'),
                onPressed: () => _uploadImage(_image!),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.photo),
              label: Text('Upload from Gallery'),
              onPressed: () => getImage(ImageSource.gallery),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera),
              label: Text('Take a Photo'),
              onPressed: () => getImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
