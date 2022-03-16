// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../config.dart';

SliverList sliverList() {
  // void checkFire() {
  // final Stream<QuerySnapshot> songSnaps =
  //     FirebaseFirestore.instance.collection('song_list').snapshots();
  // }

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
            // child: StreamBuilder<QuerySnapshot>(
            //   stream: songSnaps,
            //   builder: (BuildContext context,
            //       AsyncSnapshot<QuerySnapshot> snapshot) {
            //     print(snapshot);
            //     if (snapshot.hasError) {
            //       print(snapshot.error);
            //       return const Text('error');
            //     }
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Text('Loading!');
            //     }

            //     final data = snapshot.requireData;

            //     return ListView.builder(
            //       itemCount: data.size,
            //       itemBuilder: (context, index) {
            //         return Text('Song ${data.docs[index]['track']}');
            //       },
            //     );
            //   },
            // ),
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
      childCount: 2,
    ),
  );
}
