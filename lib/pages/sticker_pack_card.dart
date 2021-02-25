import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef onAddFunction<String> = void Function(String packID);

class StickerPackCard extends StatefulWidget {
  final List packData;
  final String packName;
  final String packID;
  final onAddFunction onAddPressed;

  const StickerPackCard(
      {Key key, this.packData, this.packName, this.packID, this.onAddPressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StickerPackCard();
  }
}

class _StickerPackCard extends State<StickerPackCard> {

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
                        widget.packName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 53,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.packData.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Image.network(
                              widget.packData[index]["url"],
                              height: 53,
                              width: 53,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 3),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                          widget.onAddPressed(widget.packID);
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
