import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
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

  Future _loginUser() async {
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

    final responseData =
        await _getCode(result.accessToken, result.refreshToken);
    await storage.write(key: "token", value: responseData["code"]);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
  }

  Future<Map<String, dynamic>> _getCode(
      String accessToken, String refreshToken) async {
    final queryParams = {
      "access_token": accessToken,
      "refresh_token": refreshToken,
      "redirectUri": "steeker://oauthredirect"
    };

    final String queryString = Uri(queryParameters: queryParams).query;

    final response = await http
        .post("https://rust.piyushdev.ml/api/auth/code?" + queryString);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  void _raisedButtonPressed() {
    print("clicked");
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
