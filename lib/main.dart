import 'package:flutter/material.dart';
import 'package:steeker/pages/landing_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steeker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LandingPage(),
    );
  }
}
