import 'dart:io';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:steeker/pages/profile_screen.dart';
import 'package:steeker/pages/sticker_page.dart';

import 'login_page.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 1;
  final List<Widget> _children = [StickerPage(), ProfileScreen()];
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  bool isDeleting = false;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Map<String, int> dirStatSync(String dirPath) {
    int fileNum = 0;
    int totalSize = 0;
    var dir = Directory(dirPath);
    try {
      if (dir.existsSync()) {
        dir
            .listSync(recursive: true, followLinks: false)
            .forEach((FileSystemEntity entity) {
          if (entity is File) {
            fileNum++;
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }

    return {'fileNum': fileNum, 'size': totalSize};
  }

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  void onDeletePressed() async {
    await analytics.logEvent(
      name: "sticker_delete_press",
    );

    if (isDeleting) return;

    await analytics.logEvent(
      name: "sticker_delete_start",
    );

    setState(() {
      isDeleting = true;
    });

    Directory _applicationDirectory = await getApplicationDocumentsDirectory();
    Map<String, int> stats = dirStatSync(_applicationDirectory.path);

    await _applicationDirectory.delete(recursive: true);

    setState(() {
      isDeleting = false;
    });

    Fluttertoast.showToast(
        msg:
            "Deleted ${stats['fileNum']} files and freed ${formatBytes(stats["size"], 2)}");
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stemker"),
      ),
      body: _children[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onDeletePressed();
        },
        backgroundColor: Colors.redAccent,
        tooltip: "Clear storage",
        child: Conditional.single(
          context: context,
          conditionBuilder: (BuildContext context) => isDeleting,
          widgetBuilder: (BuildContext context) {
            return SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white70,
                ),
              ),
            );
          },
          fallbackBuilder: (BuildContext context) {
            return Icon(
              Icons.delete,
              size: 30,
              color: Colors.white,
            );
          },
        ),
        elevation: 2,
      ),
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
