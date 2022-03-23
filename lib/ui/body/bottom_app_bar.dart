// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:music_pool_app/ui/secondPage/player/player_state.dart';
import 'package:music_pool_app/ui/secondPage/secondPage.dart';
import 'package:provider/provider.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:http/http.dart' as http;

class SongBottomAppBar extends StatefulWidget {
  const SongBottomAppBar({Key? key}) : super(key: key);

  @override
  State<SongBottomAppBar> createState() => _SongBottomAppBar();
}

class _SongBottomAppBar extends State<SongBottomAppBar> {
  var database;
  late Timer timer;
  int index = -1;

  @override
  void initState() {
    // VERY BAD WAY OF GETTING PLAYTIME
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
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
    database = FirebaseFirestore.instance.collection('default').snapshots();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
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

          if (snapshot.data.docs.isEmpty ||
              Provider.of<GlobalNotifier>(context).playing == -1) {
            return const SizedBox();
          }

          return Wrap(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.of(context).push(_createRoute());
                },
                child: Column(
                  children: [
                    const Icon(
                      Icons.arrow_drop_up_sharp,
                      color: Colors.white,
                    ),
                    Row(
                      children: [
                        if (kIsWeb) const SizedBox(width: 10),
                        Hero(
                          tag: 'icon',
                          child: Image.network(
                            snapshot.data!.docs
                                .toList()[Provider.of<GlobalNotifier>(context)
                                    .playing]
                                .data()['icon'],
                            height: 50,
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
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'track',
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 155,
                                child: Text(
                                  snapshot.data!.docs
                                      .toList()[
                                          Provider.of<GlobalNotifier>(context)
                                              .playing]
                                      .data()['track'],
                                  textScaleFactor: 2,
                                  style: const TextStyle(
                                    color: Color.fromARGB(230, 255, 255, 255),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            Hero(
                              tag: 'artist',
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 155,
                                child: Text(
                                  snapshot.data!.docs
                                      .toList()[
                                          Provider.of<GlobalNotifier>(context)
                                              .playing]
                                      .data()['artist'],
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color.fromARGB(150, 255, 255, 255),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Provider.of<GlobalNotifier>(context).playState
                            ? TextButton(
                                style: TextButton.styleFrom(
                                  primary: Config.colorStyle,
                                ),
                                onPressed: () {
                                  LiveSpotifyController.pause();
                                  Provider.of<GlobalNotifier>(context,
                                          listen: false)
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
                                  // (snapshot.data!.docs
                                  //   .toList()[Provider.of<GlobalNotifier>(
                                  //           context,
                                  //           listen: false)
                                  //       .playing]
                                  //   .data()['playback_uri']);
                                  Provider.of<GlobalNotifier>(context,
                                          listen: false)
                                      .setPlayingState(true);
                                },
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                      ],
                    ),
                    const LinearProgressIndicator(
                      value: 1,
                    ),
                    if (kIsWeb) const SizedBox(height: 10),
                  ],
                ),
              ),
              const BuildPlayerStateWidget(),
            ],
          );
        },
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const SecondPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
