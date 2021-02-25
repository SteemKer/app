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
      child: Row(
        children: <Widget>[
          Expanded(
              flex: null,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(color: Colors.greenAccent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Anime"),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Container(
                            child: Image.network(
                              "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                              height: 50,
                              width: 50,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 3),
                          ),
                          Container(
                            child: Image.network(
                              "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                              height: 50,
                              width: 50,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 3),
                          ),
                          Container(
                            child: Image.network(
                              "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                              height: 50,
                              width: 50,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 3),
                          ),
                          Container(
                            child: Image.network(
                              "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                              height: 50,
                              width: 50,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 3),
                          ),
                          Container(
                            child: Image.network(
                              "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                              height: 50,
                              width: 50,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 3),
                          ),
                          Container(
                            child: Image.network(
                              "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                              height: 50,
                              width: 50,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 3),
                          ),
                          Container(
                            child: Image.network(
                              "https://cdn.discordapp.com/emojis/459996048379609098.png?v=1",
                              height: 50,
                              width: 50,
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
              decoration: BoxDecoration(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}
