import 'package:driving_guide/screens/maps/location_screen.dart';
import 'package:flutter/material.dart';
import '../maps/map_screen.dart';
import '../traffic-prediction/traffic_screen.dart';
import '../user/user_account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    // MapScreen(37.7833, -122.4167,),
    // LocationInputScreen(),

    LocationScreen(),
    TrafficScreen(),
    UserAccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Home'),
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.map),
                  color: Colors.blue,
                  onPressed: () {
                    _onItemTapped(0);
                  },
                ),
                // Text('Map', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.traffic),
                  color: Colors.blue,
                  onPressed: () {
                    _onItemTapped(1);
                  },
                ),
                // const Text('Traffic', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: Colors.blue,
                  onPressed: () {
                    _onItemTapped(2);
                  },
                ),
                // const Text('Settings', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
