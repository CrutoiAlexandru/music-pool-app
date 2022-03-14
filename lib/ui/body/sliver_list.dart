import 'package:flutter/material.dart';
import '../config.dart';

SliverList sliverList() {
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
          color: Config.colorStyle,
          height: 100.0,
          margin: const EdgeInsets.only(top: 10),
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
                primary: Colors.white,
                elevation: 2,
                backgroundColor: Config.colorStyle),
            child: Row(
              children: [
                const Icon(
                  Icons.ac_unit,
                  size: 50,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Song name $index",
                      textScaleFactor: 2,
                      style: const TextStyle(
                          color: Color.fromARGB(230, 255, 255, 255)),
                    ),
                    Text("Song artist $index",
                        style: const TextStyle(
                            color: Color.fromARGB(150, 255, 255, 255))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      childCount: 20,
    ),
  );
}
