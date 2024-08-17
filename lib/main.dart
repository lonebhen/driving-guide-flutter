import 'package:driving_guide/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driving Guide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: _checkOnboardingCompletion(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return SplashScreen();
          }else{
            return snapshot.data == true? const HomeScreen() : const OnboardingScreen();
          }
        },
      ),
    );
  }



  Future<bool> _checkOnboardingCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingCompleted') ?? false;
  }



}


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.purple,
        ),

      ),
    );
  }
}


