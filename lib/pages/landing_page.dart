import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional_switch.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:steeker/home_page.dart';
import 'package:steeker/pages/login_page.dart';
import 'package:steeker/pages/placeholder.dart';

class LandingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LandingPage();
  }
}

class _LandingPage extends State<LandingPage> {
  final storage = new FlutterSecureStorage();
  bool loggedIn = false;
  bool fetched = false;

  Future isLoggedIn() async {
    final token = await storage.read(key: "token");
    
    if (token == null) {
      setState(() {
        loggedIn = false;
        fetched = true;
      });
      return;
    }

    final response = await http.get("https://rust.piyushdev.ml/api/users/@me",
        headers: {"Authorization": "Bearer " + token});

    if (response.statusCode != 200) {
      setState(() {
        loggedIn = false;
        fetched = true;
      });
      return;
    }

    Map<String, dynamic> data = jsonDecode(response.body);

    String name = data["username"];
    String discriminator = data["discriminator"];

    Fluttertoast.showToast(msg: "Welcome $name#$discriminator");
    setState(() {
      loggedIn = true;
      fetched = true;
    });
  }

  @override
  void initState() {
    super.initState();

    isLoggedIn().then((isLogged) => null);
  }

  @override
  Widget build(BuildContext context) {
    return ConditionalSwitch.single<String>(
      context: context,
      valueBuilder: (BuildContext context) {
        if (fetched && !loggedIn) return "A";
        if (fetched && loggedIn) return "B";

        return "C";
      },
      caseBuilders: {
        "A": (BuildContext ctx) => LoginPage(),
        "B": (BuildContext ctx) => Home(),
        "C": (BuildContext ctx) => PlaceholderWidget(Colors.black12)
      },
      fallbackBuilder: (BuildContext ctx) => LoginPage(),
    );
  }
}
