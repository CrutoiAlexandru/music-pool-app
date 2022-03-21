// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:provider/provider.dart';

import '../../global/session/session.dart';

class SongBottomAppBar extends StatefulWidget {
  const SongBottomAppBar({Key? key}) : super(key: key);

  @override
  State<SongBottomAppBar> createState() => _SongBottomAppBar();
}

class _SongBottomAppBar extends State<SongBottomAppBar> {
  var database;
  int index = -1;

  @override
  void initState() {
    database = FirebaseFirestore.instance.collection('default').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<SessionNotifier>(context).session.isNotEmpty) {
      database = FirebaseFirestore.instance
          .collection(Provider.of<SessionNotifier>(context).session)
          .snapshots();
    } else {
      database = FirebaseFirestore.instance.collection('default').snapshots();
    }

    index = Provider.of<GlobalNotifier>(context).playing;

    return BottomAppBar(
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(25), topLeft: Radius.circular(25)),
        ),
      ),
      color: Colors.black,
      child: StreamBuilder(
        stream: database,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong',
                textAlign: TextAlign.center);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 80,
              child: Text('loading', textAlign: TextAlign.center),
            );
          }

          if (snapshot.data.docs.isEmpty || index == -1) {
            return const SizedBox();
          }

          return Container(
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //       begin: Alignment.bottomCenter,
            //       end: Alignment.topCenter,
            //       colors: [Colors.black, Colors.transparent]),
            // ),
            // color: Colors.black,
            height: 75,
            margin: const EdgeInsets.only(top: 5),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Image.network(
                  snapshot.data!.docs.toList()[index].data()['icon'],
                  height: 50,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.data!.docs.toList()[index].data()['artist'],
                      textScaleFactor: 2,
                      style: const TextStyle(
                        color: Color.fromARGB(230, 255, 255, 255),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    Text(
                      snapshot.data!.docs.toList()[index].data()['track'],
                      style: const TextStyle(
                        color: Color.fromARGB(150, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
