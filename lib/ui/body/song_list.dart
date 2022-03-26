// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:provider/provider.dart';

import 'package:music_pool_app/ui/config.dart';

class SongList extends StatefulWidget {
  const SongList({Key? key}) : super(key: key);

  @override
  LiveSongList createState() => LiveSongList();
}

class LiveSongList extends State<SongList> {
  static var database;
  int playing = 0;

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

        // set state exception thrown by foundation
        // called during build
        // no drawbacks?
        Provider.of<GlobalNotifier>(context, listen: false)
            .setPlaylistSize(snapshot.requireData.size);

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
                return Draggable(
                  data: 'yes',
                  axis: Axis.horizontal,
                  feedback: listItem(snapshot, context, index),
                  child: listItem(snapshot, context, index),
                  onDragEnd: (details) {
                    // if dragged to more than half the screen
                    // remove from queue (delete from db)
                    if (details.offset.dx >
                            MediaQuery.of(context).size.width / 2 ||
                        details.offset.dx <
                            -MediaQuery.of(context).size.width / 2) {
                      if (Provider.of<GlobalNotifier>(context, listen: false)
                              .playing ==
                          index) {
                        LiveSpotifyController.pause();
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .setPlayingState(false);
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .setPlaying(-1);
                      }

                      if (index <
                              Provider.of<GlobalNotifier>(context,
                                      listen: false)
                                  .playing &&
                          Provider.of<GlobalNotifier>(context, listen: false)
                                  .playlistSize >
                              1) {
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .setPlaying(Provider.of<GlobalNotifier>(context,
                                        listen: false)
                                    .playing -
                                1);
                      } else if (Provider.of<GlobalNotifier>(context,
                                  listen: false)
                              .playlistSize ==
                          1) {
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .setPlaying(-1);
                      }

                      FirebaseFirestore.instance
                          .collection(Provider.of<SessionNotifier>(context,
                                  listen: false)
                              .session)
                          .get()
                          .then(
                        (snapshot) {
                          snapshot.docs[index].reference.delete();
                          index--;
                        },
                      );
                    }
                  },
                  childWhenDragging: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.red),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

Widget listItem(snapshot, context, index) {
  return Container(
    color: Colors.transparent,
    margin: const EdgeInsets.only(top: 10),
    child: TextButton(
      onPressed: () {
        if (Provider.of<GlobalNotifier>(context, listen: false).connected) {
          if (!Provider.of<GlobalNotifier>(context, listen: false).playState ||
              Provider.of<GlobalNotifier>(context, listen: false).playing !=
                  index) {
            if (Provider.of<GlobalNotifier>(context, listen: false).playing ==
                index) {
              LiveSpotifyController.resume();
            } else {
              // SHOULD CHECK FOR PLATFORM

              LiveSpotifyController.play(
                  snapshot.data!.docs.toList()[index].data()['playback_uri']);
            }
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlaying(index);

            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(true);
          } else {
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlaying(index);
            LiveSpotifyController.pause();
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(false);
          }
        }
      },
      style: TextButton.styleFrom(
        primary: Colors.white,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        children: [
          if (kIsWeb)
            Image.network(
              snapshot.data!.docs.toList()[index].data()['icon'],
              height: 40,
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
          const SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.data!.docs.toList()[index].data()['track'],
                textScaleFactor: 1.25,
                style: index == Provider.of<GlobalNotifier>(context).playing
                    ? const TextStyle(
                        color: Config.colorStyle, overflow: TextOverflow.clip)
                    : const TextStyle(
                        color: Color.fromARGB(200, 255, 255, 255),
                        overflow: TextOverflow.clip,
                      ),
              ),
              const SizedBox(height: 5),
              Text(
                snapshot.data!.docs.toList()[index].data()['artist'],
                textScaleFactor: 0.9,
                style: index == Provider.of<GlobalNotifier>(context).playing
                    ? const TextStyle(color: Config.colorStyleDark)
                    : const TextStyle(
                        color: Color.fromARGB(150, 255, 255, 255),
                      ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
