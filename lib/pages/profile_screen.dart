import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:steeker/pages/login_page.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileScreen();
  }
}

class _ProfileScreen extends State<ProfileScreen> {
  final storage = new FlutterSecureStorage();
  String avatarURL = "https://i.imgur.com/xLhxW6F.png";
  String username = "Clyde";

  Future isLoggedIn() async {
    final token = await storage.read(key: "token");

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    final response = await http.get("https://rust.piyushdev.ml/api/users/@me",
        headers: {"Authorization": "Bearer " + token});

    if (response.statusCode != 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    Map<String, dynamic> data = jsonDecode(response.body);

    String name = data["username"];
    String discriminator = data["discriminator"];
    String avatar = data["avatar"];

    setState(() {
      username = "$name#$discriminator";
      avatarURL = avatar;
    });
  }

  Future _logout() async {
    await storage.delete(key: "token");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    return;
  }

  @override
  void initState() {
    super.initState();

    isLoggedIn().then((isLogged) => null);
  }

  @override
  Widget build(BuildContext ctx) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 128,
              backgroundImage: NetworkImage(avatarURL),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text(
                username,
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: ElevatedButton(
                onPressed: () => _logout().then((value) => null),
                child: Text("Logout"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
