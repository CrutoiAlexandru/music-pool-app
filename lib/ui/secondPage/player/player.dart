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
  State<SongPlayer> createState() => _SongPlayer();
}

class _SongPlayer extends State<SongPlayer> {
  var database;
  int index = -1;

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
          Provider.of<GlobalNotifier>(context, listen: false).setPlaying(
              Provider.of<GlobalNotifier>(context, listen: false).playing + 1);
          if (snapshot.data!.docs
                  .toList()[Provider.of<GlobalNotifier>(context, listen: false)
                      .playing]
                  .data()['platform'] ==
              'spotify') {
            LiveSpotifyController.play(snapshot.data!.docs
                .toList()[
                    Provider.of<GlobalNotifier>(context, listen: false).playing]
                .data()['playback_uri']);
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(true);
          }
        }

        playPrevious() {
          if (Provider.of<GlobalNotifier>(context, listen: false).playing !=
              0) {
            Provider.of<GlobalNotifier>(context, listen: false).setPlaying(
                Provider.of<GlobalNotifier>(context, listen: false).playing -
                    1);
            if (snapshot.data!.docs
                    .toList()[
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .playing]
                    .data()['platform'] ==
                'spotify') {
              LiveSpotifyController.play(snapshot.data!.docs
                  .toList()[Provider.of<GlobalNotifier>(context, listen: false)
                      .playing]
                  .data()['playback_uri']);
              Provider.of<GlobalNotifier>(context, listen: false)
                  .setPlayingState(true);
            }
          } else {
            LiveSpotifyController.seekTo(0);
            LiveSpotifyController.resume();
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
                    primary: Config.colorStyle1,
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
                          primary: Config.colorStyle1,
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
                          primary: Config.colorStyle1,
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
                    primary: Config.colorStyle1,
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
                  Text(GlobalNotifier.secondsToMinutes(
                          (Provider.of<GlobalNotifier>(context).progress / 1000)
                              .floor()) +
                      ' / ' +
                      GlobalNotifier.secondsToMinutes(
                          (Provider.of<GlobalNotifier>(context).duration / 1000)
                              .floor())),
                  Slider(
                    value: Provider.of<GlobalNotifier>(context).duration != 0
                        ? Provider.of<GlobalNotifier>(context).progress
                        : 0,
                    min: 0,
                    max: Provider.of<GlobalNotifier>(context).duration,
                    onChanged: (double value) {},
                    onChangeEnd: (double value) {
                      LiveSpotifyController.seekTo(value * 1000);
                      LiveSpotifyController.resume();
                    },
                    inactiveColor: snapshot.data!.docs
                                .toList()[Provider.of<GlobalNotifier>(context,
                                        listen: false)
                                    .playing]
                                .data()['platform'] ==
                            'spotify'
                        ? Config.colorStyle1Dark
                        : Config.colorStyle2Dark,
                    activeColor: snapshot.data!.docs
                                .toList()[Provider.of<GlobalNotifier>(context,
                                        listen: false)
                                    .playing]
                                .data()['platform'] ==
                            'spotify'
                        ? Config.colorStyle1
                        : Config.colorStyle2,
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
