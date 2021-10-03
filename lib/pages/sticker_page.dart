import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:steeker/pages/sticker_pack_card.dart';
import 'package:steeker/pages/utils.dart';

import 'login_page.dart';

class StickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StickerPage();
  }
}

class _StickerPage extends State<StickerPage> {
  final storage = new FlutterSecureStorage();
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  final dio = Dio();
  final WhatsAppStickers _whatsAppStickers = WhatsAppStickers();
  final Trace myTrace = FirebasePerformance.instance.newTrace("stickers");
  int downloaded = 1;
  int toDownload = 2;
  bool _isLoading = true;
  bool screenLoaded = false;
  Directory _applicationDirectory;
  Directory _stickerPacksDirectory;
  File _stickersConfigFile;
  Map<String, dynamic> _stickerPacksConfig;
  List<dynamic> _storedStickerPacks;
  List<dynamic> data = [];
  List<Widget> cards = [];

  Future<void> _sendAnalyticsEvent(
      String eventName, Map<String, dynamic> parameters) async {
    await analytics.logEvent(name: eventName, parameters: parameters);
  }

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
        Uri.https("steeker.piyushdev.ml", "api/stickers/@me"),
        headers: {"Authorization": "Bearer " + token});

    if (response.statusCode != 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    Map<String, dynamic> apiData = jsonDecode(response.body);
    Map<String, dynamic> profileData = apiData["user"];
    List<dynamic> decodedData = apiData["data"];

    String name = profileData["username"];
    String discriminator = profileData["discriminator"];

    await analytics.setUserId("$name#$discriminator");
    await analytics.logEvent(
      name: "sticker_screen_loaded",
      parameters: {
        "id": profileData["id"],
        "user": "$name#$discriminator",
      },
    );

    List<Widget> _cards = [];
    decodedData.forEach(
      (pack) {
        if (pack["data"].length <= 3 || pack["data"].length > 30) return;
        _cards.add(
          StickerPackCard(
            packData: pack["data"],
            packName: pack["name"],
            packID: pack["pack_id"],
            onAddPressed: onAddPressed,
          ),
        );
      },
    );

    setState(() {
      data = decodedData;
      cards = _cards;
      _isLoading = false;
      screenLoaded = true;
    });

    await analytics.logEvent(
      name: "stickers_data_loaded",
      parameters: {
        "id": profileData["id"],
        "user": "$name#$discriminator",
        "stickers_length": data.length
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkFolderStructure();

    isLoggedIn().then((isLogged) => null);
  }

  void checkFolderStructure() async {
    await analytics.logEvent(
      name: "validate_folder_structure",
      parameters: {},
    );
    _applicationDirectory = await getApplicationDocumentsDirectory();
    _stickerPacksDirectory =
        Directory("${_applicationDirectory.path}/sticker_packs");
    _stickersConfigFile =
        File("${_stickerPacksDirectory.path}/sticker_packs.json");

    if (!(await _stickersConfigFile.exists())) {
      _stickersConfigFile.createSync(recursive: true);
      _stickerPacksConfig = {
        "android_play_store_link": "",
        "ios_app_store_link": "",
        "sticker_packs": [],
      };
      String fileContents = jsonEncode(_stickerPacksConfig) + "\n";
      _stickersConfigFile.writeAsStringSync(fileContents, flush: true);
    }

    _stickerPacksConfig =
        jsonDecode((await _stickersConfigFile.readAsString()));
    _storedStickerPacks = _stickerPacksConfig["sticker_packs"];
  }

  // ignore: missing_return
  onAddPressed(packID) async {
    await analytics.logEvent(
      name: "sticker_add_pressed",
      parameters: {"pack_id": packID},
    );

    final token = await storage.read(key: "token");
    final queryParams = {"pack_id": packID};
    final String queryString = Uri(queryParameters: queryParams).query;

    final HttpMetric metric = FirebasePerformance.instance.newHttpMetric(
        "https://steeker.piyushdev.ml/api/stickers/@me?$queryString",
        HttpMethod.Get);

    await metric.start();

    final response = await http.get(
        Uri.https("steeker.piyushdev.ml", "api/stickers/@me", queryParams),
        headers: {"Authorization": "Bearer " + token});

    metric
      ..responseContentType = response.headers["Content-Type"]
      ..responsePayloadSize = response.contentLength
      ..httpResponseCode = response.statusCode;
    await metric.stop();

    if (response.statusCode != 200) {
      Fluttertoast.showToast(
          msg: "Pack with ID $packID not found",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white);
      return;
    }

    Map<String, dynamic> data = jsonDecode(response.body);
    if (data["data"]["data"].length <= 2) {
      Fluttertoast.showToast(
          msg: "Pack with ID $packID has no data in it",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white);
      return;
    }

    await downloadAndAdd(data["data"]);
  }

  downloadAndAdd(Map<String, dynamic> packData) async {
    String packID = packData["pack_id"];

    await analytics.logEvent(
      name: "sticker_add_init",
      parameters: {"pack_id": packID, "pack_name": packData["name"]},
    );

    checkFolderStructure();
    var _stickerPackDirectory =
        Directory("${_stickerPacksDirectory.path}/$packID")
          ..create(recursive: true);
    final downloads = <Future>[];
    setState(() {
      _isLoading = true;
      downloaded = 0;
      toDownload = packData["data"].length;
    });

    Map<String, dynamic> packConfig = {
      "identifier": packID,
      "name": packData["name"],
      "animated_sticker_pack":
          (packData["animated"] != null) ? packData["animated"] : false,
      "publisher": "Steeker",
      "tray_image_file": "$packID.png",
      "image_data_version": "1",
      "avoid_cache": false,
      "publisher_email": "bhangalepiyush@gmail.com",
      "stickers": []
    };

    await myTrace.start();
    // tray image
    downloads.add(
      dio.download(
          packData["tray_image"], "${_stickerPackDirectory.path}/$packID.png"),
    );
    //emotes
    packData["data"].forEach(
      (emoteData) {
        downloads.add(
          dio.download(emoteData["url"],
              "${_stickerPackDirectory.path}/${emoteData["name"]}.webp"),
        );

        packConfig["stickers"].add({
          "image_file": "${emoteData["name"]}.webp",
          "emojis": ["😉"]
        });
        myTrace.incrementMetric("downloaded", 1);

        setState(() {
          downloaded = downloaded + 1;
        });
      },
    );

    await Future.wait(downloads);
    await myTrace.stop();

    _storedStickerPacks
        .removeWhere((item) => item['identifier'] == packConfig['identifier']);
    _storedStickerPacks.add(packConfig);

    _stickerPacksConfig['sticker_packs'] = _storedStickerPacks;
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String contentsOfFile = encoder.convert(_stickerPacksConfig) + "\n";
    _stickersConfigFile.deleteSync();
    _stickersConfigFile.createSync(recursive: true);
    _stickersConfigFile.writeAsStringSync(contentsOfFile, flush: true);

    _whatsAppStickers.updatedStickerPacks(packID);

    await myTrace.start();
    _whatsAppStickers.addStickerPack(
      packageName: WhatsAppPackage.Consumer,
      stickerPackIdentifier: packID,
      stickerPackName: packData["name"],
      listener: (action, result, {error}) => processResponse(
        action: action,
        result: result,
        error: error,
        successCallback: () => {
          Fluttertoast.showToast(msg: "Added ${packData["name"]}"),
        },
        context: context,
      ),
    );
    myTrace.incrementMetric("added", 1);
    await myTrace.stop();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      progressIndicator: Conditional.single(
          context: context,
          conditionBuilder: (BuildContext ctx) => screenLoaded,
          widgetBuilder: (BuildContext ctx) => CircularProgressIndicator(
                value: downloaded / toDownload,
              ),
          fallbackBuilder: (BuildContext ctx) => CircularProgressIndicator()),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
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
