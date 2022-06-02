import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MusicPool/global/global.dart';
import 'package:MusicPool/global/session/session.dart';
import 'package:MusicPool/platform_controller/spotify/spotify_controller.dart';
import 'package:MusicPool/ui/config.dart';
import 'package:provider/provider.dart';

// class meant for showing audio options such as:
//    play next
//    play previous
//    pause/play(spotify)
class SongPlayer extends StatefulWidget {
  const SongPlayer({Key? key}) : super(key: key);

  @override
  State<SongPlayer> createState() => _SongPlayer();
}

class _SongPlayer extends State<SongPlayer> {
  // stream of data from our database
  late Stream database;

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

        // method for skipping to next audio source
        playNext() {
          if (snapshot.data!.docs
                  .toList()[Provider.of<GlobalNotifier>(context, listen: false)
                          .playing +
                      1]
                  .data()['platform'] ==
              'spotify') {
            if (!SpotifyController.connectedSpotify) {
              // inform the user he's not authenticated to spotify
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
                  .toList()[Provider.of<GlobalNotifier>(context, listen: false)
                      .playing]
                  .data()['platform'] ==
              'spotify') {
            SpotifyController.play(snapshot.data!.docs
                .toList()[
                    Provider.of<GlobalNotifier>(context, listen: false).playing]
                .data()['playback_uri']);
          }
          Provider.of<GlobalNotifier>(context, listen: false)
              .setPlayingState(true);
        }

        // method for skipping to previous audio source
        playPrevious() {
          if (Provider.of<GlobalNotifier>(context, listen: false).playing !=
              0) {
            if (snapshot.data!.docs
                    .toList()[
                        Provider.of<GlobalNotifier>(context, listen: false)
                                .playing -
                            1]
                    .data()['platform'] ==
                'spotify') {
              if (!SpotifyController.connectedSpotify) {
                // inform the user he's not authenticated to spotify
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
                Provider.of<GlobalNotifier>(context, listen: false).playing -
                    1);
            if (snapshot.data!.docs
                    .toList()[
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .playing]
                    .data()['platform'] ==
                'spotify') {
              SpotifyController.play(snapshot.data!.docs
                  .toList()[Provider.of<GlobalNotifier>(context, listen: false)
                      .playing]
                  .data()['playback_uri']);
            }
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(true);
          } else {
            if (snapshot.data!.docs
                    .toList()[
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .playing]
                    .data()['platform'] ==
                'spotify') {
              SpotifyController.seekTo(0);
              SpotifyController.resume();
              Provider.of<GlobalNotifier>(context, listen: false)
                  .setPlayingState(true);
            }
          }
        }

        // in the case of spotify show a player on the second page containing the icon and song details
        // otherwise present the user with the ability of skipping audios
        if (snapshot.data!.docs
                .toList()[
                    Provider.of<GlobalNotifier>(context, listen: false).playing]
                .data()['platform'] ==
            'spotify') {
          return Column(
            children: [
              Hero(
                tag: 'icon',
                child: Center(
                  child: Image.network(
                    snapshot.data!.docs
                        .toList()[Provider.of<GlobalNotifier>(context).playing]
                        .data()['icon'],
                    height: MediaQuery.of(context).size.height * .45,
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
                    overflow: TextOverflow.ellipsis,
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
              Hero(
                tag: 'playerState',
                child: Column(
                  children: [
                    Text(GlobalNotifier.secondsToMinutes(
                            (Provider.of<GlobalNotifier>(context).progress /
                                    1000)
                                .floor()) +
                        ' / ' +
                        GlobalNotifier.secondsToMinutes(
                            (Provider.of<GlobalNotifier>(context).duration /
                                    1000)
                                .floor())),
                    Slider(
                      value: Provider.of<GlobalNotifier>(context).duration > 0
                          ? Provider.of<GlobalNotifier>(context).progress
                          : 0,
                      min: 0,
                      max: Provider.of<GlobalNotifier>(context).duration > 0
                          ? Provider.of<GlobalNotifier>(context).duration
                          : 0,
                      onChanged: (double value) {},
                      onChangeEnd: (double value) {
                        if (snapshot.data!.docs
                                .toList()[Provider.of<GlobalNotifier>(context,
                                        listen: false)
                                    .playing]
                                .data()['platform'] ==
                            'spotify') {
                          SpotifyController.seekTo(value * 1000);
                          SpotifyController.resume();
                        }
                      },
                      inactiveColor: Config.colorStyleDark,
                      activeColor: Config.colorStyle,
                    ),
                  ],
                ),
              ),
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
                            if (snapshot.data!.docs
                                    .toList()[Provider.of<GlobalNotifier>(
                                            context,
                                            listen: false)
                                        .playing]
                                    .data()['platform'] ==
                                'spotify') {
                              SpotifyController.pause();
                            }
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
                            if (snapshot.data!.docs
                                    .toList()[Provider.of<GlobalNotifier>(
                                            context,
                                            listen: false)
                                        .playing]
                                    .data()['platform'] ==
                                'spotify') {
                              SpotifyController.resume();
                            }
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
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            ],
          );
        }
      },
    );
  }
}
