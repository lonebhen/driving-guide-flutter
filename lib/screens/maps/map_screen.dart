import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreen createState() => _MapScreen();
}

class _MapScreen extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 100, color: Colors.purple),
            SizedBox(height: 20),
            Text(
              'Map Screen Content',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}