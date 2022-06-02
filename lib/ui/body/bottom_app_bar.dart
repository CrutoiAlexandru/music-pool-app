import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:MusicPool/global/global.dart';
import 'package:MusicPool/platform_controller/spotify/spotify_controller.dart';
import 'package:MusicPool/ui/config.dart';
import 'package:MusicPool/ui/secondPage/player/player.dart';
import 'package:MusicPool/ui/secondPage/player/player_state.dart';
import 'package:MusicPool/ui/secondPage/second_page.dart';
import 'package:provider/provider.dart';
import 'package:MusicPool/global/session/session.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// class for creating the bottom app bar
// Spotify show:
//    track: icon, name, artist
//    progress bar
//    play button
// Youtube show:
//    youtube player
//    next and previous buttons
//    video title
class SongBottomAppBar extends StatefulWidget {
  const SongBottomAppBar({Key? key}) : super(key: key);

  @override
  State<SongBottomAppBar> createState() => _SongBottomAppBar();
}

class _SongBottomAppBar extends State<SongBottomAppBar> {
  // the stream of data from Firestore
  late Stream database;
  // the youtube player controller meant for retaining data about the video
  // this way we can control which video we play, pause, etc...
  late YoutubePlayerController _controller;

  @override
  void initState() {
    database = FirebaseFirestore.instance
        .collection('default')
        .orderBy('order')
        .snapshots();
    super.initState();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  // auto play method to skip to next song
  autoPlayNext(snapshot) {
    if (snapshot.data!.docs
            .toList()[
                Provider.of<GlobalNotifier>(context, listen: false).playing + 1]
            .data()['platform'] ==
        'spotify') {
      if (!SpotifyController.connectedSpotify) {
        // show a message that the user is not authenticated to spotify
        return showDialog(
          context: context,
          builder: (BuildContext context) => const AlertDialog(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Config.colorStyle),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            backgroundColor: Config.back2,
            title: Text(
              'You are not logged in to Spotify!',
              style: TextStyle(color: Config.colorStyle),
            ),
          ),
        );
      }
    }

    Provider.of<GlobalNotifier>(context, listen: false).setPlaying(
        Provider.of<GlobalNotifier>(context, listen: false).playing + 1);
    if (snapshot.data!.docs
            .toList()[
                Provider.of<GlobalNotifier>(context, listen: false).playing]
            .data()['platform'] ==
        'spotify') {
      SpotifyController.play(snapshot.data!.docs
          .toList()[Provider.of<GlobalNotifier>(context, listen: false).playing]
          .data()['playback_uri']);
    }
    Provider.of<GlobalNotifier>(context, listen: false).setPlayingState(true);
  }

  // method for building/rebuilding the youtube player controller with current data
  buildYController(snapshot) {
    _controller = YoutubePlayerController(
      initialVideoId: snapshot.data!.docs
          .toList()[Provider.of<GlobalNotifier>(context).playing]
          .data()['playback_uri'],
      params: const YoutubePlayerParams(
        // not supported on web?
        autoPlay: true,
        // this enables auto play to work on android
        desktopMode: true,
        showControls: true,
        loop: false,
        showFullscreenButton: false,
        showVideoAnnotations: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<SessionNotifier>(context).session.isNotEmpty) {
      database = FirebaseFirestore.instance
          .collection(Provider.of<SessionNotifier>(context).session)
          .orderBy('order')
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
      color: Config.back1,
      child: StreamBuilder(
        stream: database,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong',
                textAlign: TextAlign.center);
          }

          if (snapshot.data.docs.isEmpty ||
              Provider.of<GlobalNotifier>(context).playing == -1) {
            return const SizedBox();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            if (snapshot.data!.docs
                    .toList()[Provider.of<GlobalNotifier>(context).playing]
                    .data()['platform'] ==
                'youtube') {
              return const SizedBox(
                height: 80,
                child: Text('loading', textAlign: TextAlign.center),
              );
            } else if (snapshot.data.docs.isEmpty) {
              return const SizedBox(
                height: 80,
                child: Text('loading', textAlign: TextAlign.center),
              );
            }
          }

          // if we are playing from youtube update the controller with actual data
          if (snapshot.data!.docs
                  .toList()[Provider.of<GlobalNotifier>(context).playing]
                  .data()['platform'] ==
              'youtube') {
            buildYController(snapshot);
            SpotifyController.pause();
          }

          return Wrap(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.transparent,
                ),
                onPressed: snapshot.data!.docs
                            .toList()[Provider.of<GlobalNotifier>(context,
                                    listen: false)
                                .playing]
                            .data()['platform'] ==
                        'spotify'
                    ? () {
                        Navigator.of(context).push(_createRoute());
                      }
                    : () {},
                child: Column(
                  children: [
                    snapshot.data!.docs
                                .toList()[Provider.of<GlobalNotifier>(context)
                                    .playing]
                                .data()['platform'] ==
                            'spotify'
                        ? const Icon(
                            Icons.arrow_drop_up_sharp,
                            color: Colors.white,
                          )
                        : const SizedBox(
                            height: 20,
                          ),
                    Row(
                      children: [
                        if (kIsWeb) const SizedBox(width: 10),
                        // only build the icon for spotify
                        // for youtube we will show a player to control the video
                        snapshot.data!.docs
                                    .toList()[
                                        Provider.of<GlobalNotifier>(context)
                                            .playing]
                                    .data()['platform'] ==
                                'spotify'
                            ? Hero(
                                tag: 'icon',
                                child: Image.network(
                                  snapshot.data!.docs
                                      .toList()[
                                          Provider.of<GlobalNotifier>(context)
                                              .playing]
                                      .data()['icon'],
                                  height: 50,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width - 40,
                                child: YoutubePlayerIFrame(
                                  controller: _controller,
                                ),
                              ),
                        const SizedBox(width: 10),
                        if (snapshot.data!.docs
                                .toList()[Provider.of<GlobalNotifier>(context)
                                    .playing]
                                .data()['platform'] ==
                            'spotify')
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: 'track',
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 155,
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
                                  width:
                                      MediaQuery.of(context).size.width - 155,
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
                        // the play pause button is only needed for spotify
                        // youtube can just have a video player for controlling the video
                        if (snapshot.data!.docs
                                .toList()[Provider.of<GlobalNotifier>(context)
                                    .playing]
                                .data()['platform'] ==
                            'spotify')
                          Provider.of<GlobalNotifier>(context).playState
                              ? TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Config.colorStyle,
                                  ),
                                  onPressed: () {
                                    SpotifyController.pause();
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
                                    SpotifyController.resume();
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
                    // youtube value builder for auto play support
                    if (snapshot.data!.docs
                            .toList()[
                                Provider.of<GlobalNotifier>(context).playing]
                            .data()['platform'] ==
                        'youtube')
                      YoutubeValueBuilder(
                        controller: _controller,
                        builder: (context, value) {
                          if (value.playerState == PlayerState.ended) {
                            // when the video is over auto play next in queue
                            autoPlayNext(snapshot);
                          }

                          return const SizedBox();
                        },
                      ),
                    if (snapshot.data!.docs
                            .toList()[
                                Provider.of<GlobalNotifier>(context).playing]
                            .data()['platform'] ==
                        'youtube')
                      const SongPlayer(),
                    if (snapshot.data!.docs
                            .toList()[
                                Provider.of<GlobalNotifier>(context).playing]
                            .data()['platform'] ==
                        'youtube')
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text(
                            snapshot.data!.docs
                                .toList()[Provider.of<GlobalNotifier>(context)
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
                  ],
                ),
              ),
              // the player state widget is only needed by spotify
              // for youtube we must build a player(maybe instead of showing the icon)
              if (snapshot.data!.docs
                      .toList()[Provider.of<GlobalNotifier>(context).playing]
                      .data()['platform'] ==
                  'spotify')
                const BuildPlayerStateWidget(),
            ],
          );
        },
      ),
    );
  }
}

// route created for going to the second page(the spotify player)
// this is only for spotify in order to show more optionality in the user controls
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
