import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/platform_controller/spotify/spotify_controller.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';

// list item(used in the audio queue) for our spotify based items
// made of a track: title, artist, icon
Widget listItemSpot(snapshot, context, index) {
  return Container(
    color: Colors.transparent,
    margin: const EdgeInsets.only(top: 10),
    child: TextButton(
      onPressed: () {
        if (Provider.of<GlobalNotifier>(context, listen: false)
            .connectedSpotify) {
          if (!Provider.of<GlobalNotifier>(context, listen: false).playState ||
              Provider.of<GlobalNotifier>(context, listen: false).playing !=
                  index) {
            if (Provider.of<GlobalNotifier>(context, listen: false).playing ==
                index) {
              SpotifyController.resume();
            } else {
              // every time a song is played we need to check for the platform to play from
              // this is set when we add the song to our queue/database
              if (snapshot.data!.docs.toList()[index].data()['platform'] ==
                  'spotify') {
                SpotifyController.play(
                    snapshot.data!.docs.toList()[index].data()['playback_uri']);
              }
            }
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlaying(index);

            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(true);
          } else {
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlaying(index);
            SpotifyController.pause();
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(false);
          }
        }
      },
      style: TextButton.styleFrom(
        primary: Config.colorStyle,
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        children: [
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  snapshot.data!.docs.toList()[index].data()['track'],
                  textScaleFactor: 1.25,
                  style: index == Provider.of<GlobalNotifier>(context).playing
                      ? snapshot.data!.docs
                                  .toList()[index]
                                  .data()['platform'] ==
                              'spotify'
                          ? const TextStyle(
                              color: Config.colorStyle1,
                              overflow: TextOverflow.ellipsis)
                          : const TextStyle(
                              color: Config.colorStyle,
                              overflow: TextOverflow.ellipsis)
                      : const TextStyle(
                          color: Color.fromARGB(200, 255, 255, 255),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                snapshot.data!.docs.toList()[index].data()['artist'],
                textScaleFactor: 0.9,
                style: index == Provider.of<GlobalNotifier>(context).playing
                    ? snapshot.data!.docs.toList()[index].data()['platform'] ==
                            'spotify'
                        ? const TextStyle(color: Config.colorStyle1Dark)
                        : const TextStyle(color: Config.colorStyleDark)
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
