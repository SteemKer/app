import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'login_page.dart';

class StickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StickerPage();
  }
}

class _StickerPage extends State<StickerPage> {
  final storage = new FlutterSecureStorage();
  List<dynamic> data = [];
  List<Widget> cards = [];

  Future isLoggedIn() async {
    final token = await storage.read(key: "token");

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    final response = await http.get(
        "https://rust.piyushdev.ml/api/stickers/@me",
        headers: {"Authorization": "Bearer " + token});

    if (response.statusCode != 200) {
      print(response.statusCode);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    List<dynamic> decodedData = jsonDecode(response.body);
    List<Widget> _cards = [];
    decodedData.forEach((pack) {
      if (pack["data"].length <= 0) return;
      _cards.add(Container(
        height: 200,
        width: (MediaQuery.of(context).size.width -
            20 * MediaQuery.of(context).size.width / 100),
        padding: EdgeInsets.all(4),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          color: Colors.white12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                pack["name"],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              ElevatedButton(
                onPressed: () {
                  onAddPressed(pack["pack_id"]);
                },
                child: Text("Add"),
              ),
            ],
          ),
        ),
      ));
    });

    setState(() {
      data = decodedData;
      cards = _cards;
    });
  }

  @override
  void initState() {
    super.initState();

    isLoggedIn().then((isLogged) => null);
  }

  // ignore: missing_return
  onAddPressed(packID) async {
    print(packID);
    final token = await storage.read(key: "token");
    final queryParams = {"pack_id": packID};
    final String queryString = Uri(queryParameters: queryParams).query;

    final response = await http.get(
        "https://rust.piyushdev.ml/api/stickers/@me?$queryString",
        headers: {"Authorization": "Bearer " + token});

    if (response.statusCode != 200) {
      Fluttertoast.showToast(
          msg: "Pack with ID $packID not found",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white);
      return;
    }

    Map<String, dynamic> data = jsonDecode(response.body);
    if (data["data"].length <= 0) {
      Fluttertoast.showToast(
          msg: "Pack with ID $packID has no data in it",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white);
      return;
    }
  }

  Future downloadFromServer() async {
    var applicationsDocumentDirectory = await getApplicationDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: cards,
          ),
        ),
      ),
    );
  }
}
