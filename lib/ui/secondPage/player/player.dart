// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';

class SongPlayer extends StatefulWidget {
  const SongPlayer({Key? key}) : super(key: key);

  @override
  State<SongPlayer> createState() => LiveSongPlayer();
}

class LiveSongPlayer extends State<SongPlayer> {
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

    return StreamBuilder(
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

        if (snapshot.data.docs.isEmpty ||
            Provider.of<GlobalNotifier>(context).playing == -1) {
          return const SizedBox();
        }

        playNext() {
          Provider.of<GlobalNotifier>(context, listen: false).playingNumber(
              Provider.of<GlobalNotifier>(context, listen: false).playing + 1);
          LiveSpotifyController.play(snapshot.data!.docs
              .toList()[
                  Provider.of<GlobalNotifier>(context, listen: false).playing]
              .data()['playback_uri']);
          Provider.of<GlobalNotifier>(context, listen: false)
              .setPlayingState(true);
        }

        playPrevious() {
          if (Provider.of<GlobalNotifier>(context, listen: false).playing !=
              0) {
            Provider.of<GlobalNotifier>(context, listen: false).playingNumber(
                Provider.of<GlobalNotifier>(context, listen: false).playing -
                    1);
            LiveSpotifyController.play(snapshot.data!.docs
                .toList()[
                    Provider.of<GlobalNotifier>(context, listen: false).playing]
                .data()['playback_uri']);
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(true);
          }
        }

        return Column(
          children: [
            Hero(
              tag: 'icon',
              child: Center(
                child: Image.network(
                  snapshot.data!.docs
                      .toList()[Provider.of<GlobalNotifier>(context).playing]
                      .data()['icon'],
                  // width: MediaQuery.of(context).size.width < 600
                  //     ? MediaQuery.of(context).size.width - 20
                  //     : 580,
                  height: MediaQuery.of(context).size.height * .4,
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
              ),
            ),
            const SizedBox(height: 20),
            Hero(
              tag: 'track',
              child: Text(
                snapshot.data!.docs
                    .toList()[Provider.of<GlobalNotifier>(context).playing]
                    .data()['track'],
                textScaleFactor: 2,
                style: const TextStyle(
                  color: Color.fromARGB(230, 255, 255, 255),
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
            Hero(
              tag: 'artist',
              child: Text(
                snapshot.data!.docs
                    .toList()[Provider.of<GlobalNotifier>(context).playing]
                    .data()['artist'],
                style: const TextStyle(
                  color: Color.fromARGB(150, 255, 255, 255),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Config.colorStyle,
                  ),
                  onPressed: playPrevious,
                  child: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(width: 40),
                Provider.of<GlobalNotifier>(context).playState
                    ? TextButton(
                        style: TextButton.styleFrom(
                          primary: Config.colorStyle,
                        ),
                        onPressed: () {
                          LiveSpotifyController.pause();
                          Provider.of<GlobalNotifier>(context, listen: false)
                              .setPlayingState(false);
                        },
                        child: const Icon(
                          Icons.pause,
                          color: Colors.white,
                          size: 50,
                        ),
                      )
                    : TextButton(
                        style: TextButton.styleFrom(
                          primary: Config.colorStyle,
                        ),
                        onPressed: () {
                          LiveSpotifyController.resume();
                          Provider.of<GlobalNotifier>(context, listen: false)
                              .setPlayingState(true);
                        },
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                const SizedBox(width: 40),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Config.colorStyle,
                  ),
                  onPressed: playNext,
                  child: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 50,
                  ),
                )
              ],
            ),
            Hero(
              tag: 'playerState',
              child: Column(
                children: [
                  Text(Provider.of<GlobalNotifier>(context)
                          .progress
                          .toString() +
                      ' / ' +
                      Provider.of<GlobalNotifier>(context).duration.toString()),
                  Slider(
                    value: Provider.of<GlobalNotifier>(context).duration != 0
                        ? (Provider.of<GlobalNotifier>(context).progress /
                                Provider.of<GlobalNotifier>(context).duration) *
                            1000
                        : 0,
                    min: 0,
                    max: 1000,
                    onChanged: (double value) {},
                    onChangeEnd: (double value) {
                      LiveSpotifyController.seekTo(value *
                          Provider.of<GlobalNotifier>(context, listen: false)
                              .duration);
                      LiveSpotifyController.resume();
                    },
                    inactiveColor: Config.colorStyleDark,
                    activeColor: Config.colorStyle,
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
