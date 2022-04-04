// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/platform_controller/spotify/spotify_controller.dart';
import 'package:music_pool_app/platform_controller/youtube/youtube_list_widget.dart';
import 'package:provider/provider.dart';
import 'package:music_pool_app/platform_controller/spotify/spotify_list_widget.dart';

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
    database = FirebaseFirestore.instance
        .collection('default')
        .orderBy('order')
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<SessionNotifier>(context).session.isNotEmpty) {
      database = FirebaseFirestore.instance
          .collection(Provider.of<SessionNotifier>(context).session)
          .orderBy('order')
          .snapshots();
    } else {
      database = FirebaseFirestore.instance
          .collection('default')
          .orderBy('order')
          .snapshots();
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
                return LongPressDraggable(
                  data: 'yes',
                  axis: Axis.horizontal,
                  feedback:
                      snapshot.data!.docs.toList()[index].data()['platform'] ==
                              'spotify'
                          ? listItemSpot(snapshot, context, index)
                          : listItemYT(snapshot, context, index),
                  child:
                      snapshot.data!.docs.toList()[index].data()['platform'] ==
                              'spotify'
                          ? listItemSpot(snapshot, context, index)
                          : listItemYT(snapshot, context, index),
                  childWhenDragging: SizedBox(
                    // height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: Icon(Icons.playlist_remove,
                          color: Config.colorStyleDark),
                    ),
                  ),
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
                        SpotifyController.pause();
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
                          .orderBy('order')
                          .get()
                          .then(
                        (snapshot) {
                          snapshot.docs[index].reference.delete();
                          index--;
                        },
                      );
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
