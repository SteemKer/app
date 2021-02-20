import 'package:flutter/material.dart';

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  Widget build(BuildContext ctx) {
    return Container(
        color: color,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(30),
            child: Image.network(
              "https://i.imgur.com/14NIvQq.png",
              height: (MediaQuery.of(ctx).size.height * 30 / 100),
              width: (MediaQuery.of(ctx).size.width * 70 / 100),
            ),
          ),
        ));
  }
}
