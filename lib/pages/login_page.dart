import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  void _raisedButtonPressed() {
    print("clicked");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: NetworkImage("https://i.imgur.com/UoJpQig.jpg"),
        fit: BoxFit.cover,
      )),
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
                                color: Colors.black54
                              ),
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
