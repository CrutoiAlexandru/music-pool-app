// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class BuildPlayerStateWidget extends StatefulWidget {
  const BuildPlayerStateWidget({Key? key}) : super(key: key);

  @override
  State<BuildPlayerStateWidget> createState() => _BuildPlayerStateWidget();
}

class _BuildPlayerStateWidget extends State<BuildPlayerStateWidget> {
  late Timer timer;
  var database;
  var spotifyState;

  @override
  void initState() {
    database = FirebaseFirestore.instance.collection('default').snapshots();
    getSongLength();
    setTimer();
    super.initState();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  getSongLength() async {
    var url = Uri.https('api.spotify.com', '/v1/me/player');
    final res = await http.get(url,
        headers: {'Authorization': 'Bearer ${LiveSpotifyController.token}'});

    var body = jsonDecode(res.body);
    if (body['item']['duration_ms'].runtimeType == int) {
      int duration = body['item']['duration_ms'];

      Provider.of<GlobalNotifier>(context, listen: false).setDuration(duration);
    }
  }

  setTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        getSpotifyState();
        var url = Uri.https('api.spotify.com', '/v1/me/player');
        final res = await http.get(url, headers: {
          'Authorization': 'Bearer ${LiveSpotifyController.token}'
        });

        var body = jsonDecode(res.body);
        if (body['progress_ms'].runtimeType == int) {
          if (body['progress_ms'] != 0) {
            int progress = body['progress_ms'];

            Provider.of<GlobalNotifier>(context, listen: false)
                .setProgress(progress);
          }
        }
      },
    );
  }

  cancelTimer() {
    timer.cancel();
  }

  getSpotifyState() async {
    spotifyState = await LiveSpotifyController.getPlayerState();
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

    // everytime the song changes get its length
    // executes too many times because of the way functions() and providers work
    // not sure !?
    if ((Provider.of<GlobalNotifier>(context).progress / 1000).floor() == 0) {
      getSongLength();
    }

    if (Provider.of<GlobalNotifier>(context).playState) {
      if (!timer.isActive) {
        setTimer();
      }
    } else {
      if (timer.isActive) {
        cancelTimer();
      }
    }

    // need better autoplay methods
    if ((Provider.of<GlobalNotifier>(context).progress / 1000).floor() ==
            (Provider.of<GlobalNotifier>(context).duration / 1000).floor() &&
        Provider.of<GlobalNotifier>(context).duration != 0) {
      Provider.of<GlobalNotifier>(context, listen: false).setOver(true);
    }

    autoPlayNext(snapshot) {
      // if (snapshot.connectionState != ConnectionState.waiting) {
      Provider.of<GlobalNotifier>(context, listen: false).playingNumber(
          Provider.of<GlobalNotifier>(context, listen: false).playing + 1);
      LiveSpotifyController.play(snapshot.data!.docs
          .toList()[Provider.of<GlobalNotifier>(context, listen: false).playing]
          .data()['playback_uri']);
      Provider.of<GlobalNotifier>(context, listen: false).setPlayingState(true);
      Provider.of<GlobalNotifier>(context, listen: false).setOver(false);
      // } else {
      // return const CircularProgressIndicator();
      // }
    }

    return StreamBuilder(
      stream: database,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong',
              textAlign: TextAlign.center);
        }

        if (snapshot.connectionState != ConnectionState.waiting &&
                snapshot.data.docs.isEmpty ||
            Provider.of<GlobalNotifier>(context).playing == -1) {
          return const SizedBox();
        }

        // IN CASE DOUBLE TO INT TRANSLATION RESULTS THE END PROGRESS TO BE LESS THAN THE DURATION VALUE
        // WOULD WORK
        // NEED TO UPDATE PLAY STATE MORE OFTEN
        if (spotifyState.isPaused &&
            !Provider.of<GlobalNotifier>(context).over &&
            Provider.of<GlobalNotifier>(context).playState) {
          Provider.of<GlobalNotifier>(context, listen: false).setProgress(
              Provider.of<GlobalNotifier>(context, listen: false).duration);
          print('LINE 139');
        }

        // THIS DOESN'T WORK
        if (Provider.of<GlobalNotifier>(context).over) {
          // timer =
          // Timer.periodic(
          //   const Duration(seconds: 1),
          //   (timer) async {
          if (spotifyState != null) {
            // if (spotifyState.isPaused) {
            getSpotifyState();

            // currently the method gets executed while building, not ok but works in case of not being able to wrok around it
            autoPlayNext(snapshot);
            print('GOT SOMETHING');

            Provider.of<GlobalNotifier>(context, listen: false).setOver(false);
            spotifyState = null;
            // }
          } else {
            print('EMPTY');
          }
          // },
          // );
        }
        // else {
        // timer.cancel();
        // }

        return Hero(
          tag: 'playerState',
          child: Column(
            children: [
              Text(Provider.of<GlobalNotifier>(context).progress.toString() +
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
                inactiveColor: Config
                    .colorStyleDark, //const Color.fromARGB(255, 59, 59, 59),
                activeColor: Config.colorStyle,
              ),
            ],
          ),
        );
      },
    );
  }
}
