import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:steeker/pages/landing_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  final storage = new FlutterSecureStorage();
  final FlutterAppAuth appAuth = FlutterAppAuth();
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  Future<void> _sendAnalyticsEvent(
      String eventName, Map<String, dynamic> parameters) async {
    await analytics.logEvent(name: eventName, parameters: parameters);
  }

  Future _loginUser() async {
    await _sendAnalyticsEvent("login_click", {});
    final Trace oauthTrace = FirebasePerformance.instance.newTrace("login");

    await oauthTrace.start();
    final AuthorizationTokenResponse result =
        await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest("793424606324981770", "steeker://oauthredirect",
          serviceConfiguration: AuthorizationServiceConfiguration(
            "https://discordapp.com/api/oauth2/authorize",
            "https://discordapp.com/api/oauth2/token",
          ),
          scopes: ["email", "identify"],
          promptValues: ["none"]),
    );

    oauthTrace.incrementMetric("oauth_request", 1);

    final responseData =
        await _getCode(result.accessToken, result.refreshToken);
    oauthTrace.incrementMetric("oauth_api_code_exchange", 1);

    await storage.write(key: "token", value: responseData["code"]);
    oauthTrace.incrementMetric("oauth_store_token", 1);
    await analytics.logLogin(loginMethod: "oauth");
    await _sendAnalyticsEvent("user_logged_in", {});

    await oauthTrace.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
  }

  // ignore: missing_return
  Future<Map<String, dynamic>> _getCode(
      String accessToken, String refreshToken) async {
    final queryParams = {
      "access_token": accessToken,
      "refresh_token": refreshToken,
      "redirectUri": "steeker://oauthredirect"
    };

    final String queryString = Uri(queryParameters: queryParams).query;

    final HttpMetric metric = FirebasePerformance.instance.newHttpMetric(
        "https://steeker.piyushdev.ml/api/auth/code?$queryString",
        HttpMethod.Post);

    await metric.start();
    final response = await http.post(Uri.https(
        "https://steeker.piyushdev.ml", "api/auth/code", queryParams));

    metric
      ..responseContentType = response.headers["Content-Type"]
      ..responsePayloadSize = response.contentLength
      ..httpResponseCode = response.statusCode;
    await metric.stop();

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      Fluttertoast.showToast(msg: "${response.statusCode} - ${response.body}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _raisedButtonPressed() {
    _loginUser().then((value) => null);
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: "token");
    return token != null;
  }

  @override
  void initState() {
    super.initState();

    isLoggedIn().then((_) => null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://i.imgur.com/UoJpQig.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15.0),
                ),
              ),
              color: Colors.white,
              elevation: 10,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 10,
                height: (MediaQuery.of(context).size.height * 20 / 100),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                  child: Column(
                    children: [
                      Container(
                        child: ElevatedButton.icon(
                          onPressed: _raisedButtonPressed,
                          icon: Icon(Icons.login_rounded),
                          label: Text("Discord"),
                        ),
                      ),
                      Container(
                        height: (MediaQuery.of(context).size.height * 5 / 100),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Can't login? Contact Piyush#4332",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: (MediaQuery.of(context).size.height * 5 / 100),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Not Whitelisted? You were never meant to be 😉",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
