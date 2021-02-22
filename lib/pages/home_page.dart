import 'package:flutter/material.dart';
import 'package:steeker/pages/placeholder.dart';
import 'package:steeker/pages/profile_screen.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 1;
  final List<Widget> _children = [
    PlaceholderWidget(Colors.black12),
    ProfileScreen()
  ];

  void onTabTapped(int index) {
    print(index);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stemker"),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: new Icon(Icons.polymer), label: "Stickers"),
          BottomNavigationBarItem(
              icon: new Icon(Icons.verified_user), label: "Profile"),
        ],
      ),
    );
  }
}
