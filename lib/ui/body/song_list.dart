// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/session/session.dart';
import 'package:provider/provider.dart';

import '../config.dart';

class SongList extends StatefulWidget {
  const SongList({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  LiveSongList createState() => LiveSongList();
}

class LiveSongList extends State<SongList> {
  static var database;

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
    return StreamBuilder(
      stream: database,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: snapshot.requireData.size,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  color: Config.colorStyle,
                  height: 100.0,
                  margin: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: () {
                      print(index);
                    },
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        elevation: 2,
                        backgroundColor: Config.colorStyle),
                    child: Row(
                      children: [
                        Image.network(
                          snapshot.data!.docs.toList()[index].data()['icon'],
                          height: 75,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
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
                              snapshot.data!.docs
                                  .toList()[index]
                                  .data()['artist'],
                              textScaleFactor: 2,
                              style: const TextStyle(
                                color: Color.fromARGB(230, 255, 255, 255),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              snapshot.data!.docs
                                  .toList()[index]
                                  .data()['track'],
                              style: const TextStyle(
                                color: Color.fromARGB(150, 255, 255, 255),
                              ),
                            ),
                          ],
                        ),
                        // const Spacer(), // SHOW WHICH SONG IS PLAYING
                        // const SizedBox(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
