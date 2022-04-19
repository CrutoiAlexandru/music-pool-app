import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/platform_controller/spotify/spotify_controller.dart';
import 'package:music_pool_app/platform_controller/youtube/youtube_list_widget.dart';
import 'package:provider/provider.dart';
import 'package:music_pool_app/platform_controller/spotify/spotify_list_widget.dart';

import 'package:music_pool_app/ui/config.dart';

// class made for showing the widget containing the list of audio items
// show data about the items and allows the user to play or paused certain audio
//    in the case of youtube the second click will remove the player from the screen
//    in the case of spotify the second click will pause the song
class SongList extends StatefulWidget {
  const SongList({Key? key}) : super(key: key);

  @override
  State<SongList> createState() => _SongList();
}

class _SongList extends State<SongList> {
  // stream of data from database
  static late Stream database;
  // current playing audio(represented by an integer in the list, position)
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
        // we need this in order to know the current playlist size
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
