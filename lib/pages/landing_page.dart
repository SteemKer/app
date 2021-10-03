import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional_switch.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:steeker/pages/login_page.dart';
import 'package:steeker/pages/placeholder.dart';
import 'package:steeker/pages/update_screen.dart';

import 'home_page.dart';

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

  Future checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    if (version.contains("dev")) {
      return;
    }

    final response = await http.get(
      Uri.https("steeker.netlify.app", "data.json"),
    );

    if (response.statusCode != 200) {
      Fluttertoast.showToast(
        msg: "Couldn't fetch data from API. contact Piyush#4332 for more info",
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              body: PlaceholderWidget(Colors.black26),
            );
          },
        ),
      );

      return;
    }

    Map<String, dynamic> data = jsonDecode(response.body);

    print(data["latestVersion"]);
    print(version);

    if (data["latestVersion"] != version) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UpdatePage(),
        ),
      );
    }
  }

  Future isLoggedIn() async {
    Map<Permission, PermissionStatus> permissions =
        await [Permission.storage].request();

    final token = await storage.read(key: "token");

    if (!this.mounted) return;
    if (token == null) {
      setState(() {
        loggedIn = false;
        fetched = true;
      });
      return;
    }

    final response = await http.get(
        Uri.https("steeker.piyushdev.ml", "api/users/@me"),
        headers: {"Authorization": "Bearer " + token});

    if (!this.mounted) return;

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

    checkVersion().then((value) => null); //.then(() => null);
    if (this.mounted) {
      isLoggedIn().then((isLogged) => null);
    }
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
