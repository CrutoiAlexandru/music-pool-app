// ignore_for_file: import_of_legacy_library_into_null_safe, use_key_in_widget_constructors, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class SliverSongList extends StatelessWidget {
  final data = [];
  var list;

  final _songsList =
      FirebaseFirestore.instance.collection('song_list').snapshots();

  Widget builder(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _songsList,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        list = snapshot.data!.docs.toList();

        for (int i = 0; i < list.length; i++) {
          data.add(list[i].data());
        }

        return Text(data[0].toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
          // (BuildContext context, int index) {
          // builder(context),
          const Text("data"),

      // return Container(
      //   color: Config.colorStyle,
      //   height: 100.0,
      //   margin: const EdgeInsets.only(top: 10),
      //   child: TextButton(
      //     onPressed: () {},
      //     style: TextButton.styleFrom(
      //         primary: Colors.white,
      //         elevation: 2,
      //         backgroundColor: Config.colorStyle),
      //     child: Row(
      //       children: [
      //         builder(context, index),
      //         const Icon(
      //           Icons.ac_unit,
      //           size: 50,
      //         ),
      //         Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               "Song name $index",
      //               textScaleFactor: 2,
      //               style: const TextStyle(
      //                   color: Color.fromARGB(230, 255, 255, 255)),
      //             ),
      //             Text("Song artist $index",
      //                 style: const TextStyle(
      //                     color: Color.fromARGB(150, 255, 255, 255))),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // );
      // },
      // childCount: 2,
    );
  }
}
