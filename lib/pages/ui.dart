import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Ui extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Ui();
  }
}

class _Ui extends State<Ui> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: Card(
        color: Colors.white,
        elevation: 10,
        child: Row(
          children: <Widget>[
            Expanded(
                flex: null,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  // decoration: BoxDecoration(color: Colors.greenAccent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10, top: 12, bottom: 10),
                        child: Text(
                          "Anime",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 53,
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          scrollDirection: Axis.horizontal,
                          children: [
                            Container(
                              child: Image.network(
                                "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                                height: 53,
                                width: 53,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                            Container(
                              child: Image.network(
                                "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                                height: 53,
                                width: 53,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                            Container(
                              child: Image.network(
                                "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                                height: 53,
                                width: 53,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                            Container(
                              child: Image.network(
                                "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                                height: 53,
                                width: 53,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                            Container(
                              child: Image.network(
                                "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                                height: 53,
                                width: 53,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                            Container(
                              child: Image.network(
                                "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                                height: 53,
                                width: 53,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                            Container(
                              child: Image.network(
                                "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                                height: 53,
                                width: 53,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            Expanded(
              flex: 1,
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  // decoration: BoxDecoration(color: Colors.blueGrey),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Scaffold.of(context)
                              .showSnackBar(SnackBar(content: Text("Clicked")));
                        },
                        child: Text("Add"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Scaffold.of(context)
                              .showSnackBar(SnackBar(content: Text("Soon")));
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.orangeAccent),
                        child: Text("Share"),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
