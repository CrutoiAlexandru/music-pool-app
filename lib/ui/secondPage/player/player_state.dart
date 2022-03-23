import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class BuildPlayerStateWidget extends StatefulWidget {
  const BuildPlayerStateWidget({Key? key}) : super(key: key);

  @override
  State<BuildPlayerStateWidget> createState() => _BuildPlayerStateWidget();
}

class _BuildPlayerStateWidget extends State<BuildPlayerStateWidget> {
  late Timer timer;
  var prog = 0;
  var duration = 0;
  var database;

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
    print('SAFE');
    var url = Uri.https('api.spotify.com', '/v1/me/player');
    final res = await http.get(url,
        headers: {'Authorization': 'Bearer ${LiveSpotifyController.token}'});

    var body = jsonDecode(res.body);
    if (body['item']['duration_ms'].runtimeType == int) {
      int duration = body['item']['duration_ms'];

      Provider.of<GlobalNotifier>(context, listen: false)
          .setDuration((duration / 1000).floor());
    }
  }

  setTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      print('running');
      var url = Uri.https('api.spotify.com', '/v1/me/player');
      final res = await http.get(url,
          headers: {'Authorization': 'Bearer ${LiveSpotifyController.token}'});

      var body = jsonDecode(res.body);
      if (body['progress_ms'].runtimeType == int) {
        int progress = body['progress_ms'];

        Provider.of<GlobalNotifier>(context, listen: false)
            .setProgress((progress / 1000).floor());
      }
    });
  }

  cancelTimer() {
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double progressIndicator = 0.0;

    if (Provider.of<SessionNotifier>(context).session.isNotEmpty) {
      database = FirebaseFirestore.instance
          .collection(Provider.of<SessionNotifier>(context).session)
          .snapshots();
    } else {
      database = FirebaseFirestore.instance.collection('default').snapshots();
    }

    // everytime the song changes get its length
    if (Provider.of<GlobalNotifier>(context).progress == 0) {
      Future.delayed(const Duration(seconds: 1), () {
        getSongLength();
      });
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

    prog = Provider.of<GlobalNotifier>(context).progress;
    duration = Provider.of<GlobalNotifier>(context).duration;

    if (duration != 0) {
      progressIndicator = prog / duration;
    }

    if (prog == duration - 1 && prog != 0) {
      print('DONE');
      Provider.of<GlobalNotifier>(context, listen: false).setOver(true);
    }

    // return Column(
    // children: [
    // Text(prog.toString() + '/' + duration.toString()),
    // LinearProgressIndicator(
    // value: progressIndicator,
    // ),
    // ],
    // );

    return StreamBuilder(
        stream: database,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (Provider.of<GlobalNotifier>(context).over) {
            Provider.of<GlobalNotifier>(context, listen: false).playingNumber(
                Provider.of<GlobalNotifier>(context, listen: false).playing +
                    1);
            LiveSpotifyController.play(snapshot.data!.docs
                .toList()[
                    Provider.of<GlobalNotifier>(context, listen: false).playing]
                .data()['playback_uri']);
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(true);
            Provider.of<GlobalNotifier>(context, listen: false).setOver(false);
          }

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

          return Column(
            children: [
              Text(prog.toString() + '/' + duration.toString()),
              LinearProgressIndicator(
                value: progressIndicator,
              ),
            ],
          );
        });
  }
}
