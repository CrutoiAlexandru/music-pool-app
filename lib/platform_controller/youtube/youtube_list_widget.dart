import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';
// PREFEREBLY USE _FLUTTER THAN _IFRAME
// IFRAME SEEMS BROKEN
// this is for android and ios only
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// iframe is for web yt playback
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// the ListView item for the youtube player in queue

// MAKE STATEFUL WIDGET? maybe that is why play pause doesn't work
Widget listItemYT(snapshot, context, index) {
  /** 
  ADDING A YOUTUBE PLAYER HERE DOES NOT HELP
  WE SHOULD REPLACE THIS BY AN IMAGE
  ONLY CREATE A PLAYER WHEN THE VIDEO IS PLAYED
  MEANING WE REPLACE THE BOTTOM SPOTIFY BAR WITH ONE DESIGNED FOR THE YOUTUBE PLAYER
  SAME FOR THE PLAYER(MUSIC)
  */
  // YoutubePlayerController _controller = YoutubePlayerController(
  //   initialVideoId: snapshot.data!.docs.toList()[index].data()['playback_uri'],
  //   // flags: const YoutubePlayerFlags(
  //   params: const YoutubePlayerParams(
  //     autoPlay: false,
  //     // hideControls: true,
  //     showControls: false,
  //     loop: false,
  //     // controlsVisibleAtStart: false,
  //     showFullscreenButton: false,
  //     showVideoAnnotations: false,
  //     // hideThumbnail: true,
  //   ),
  // );

  return Container(
    color: Colors.transparent,
    margin: const EdgeInsets.only(top: 10),
    child: TextButton(
      onPressed: () {
        // WHEN PRESSED JUST OPEN THE VIDEO PLAYER WITH AUTOPLAY ON
        if (!Provider.of<GlobalNotifier>(context, listen: false).playState ||
            Provider.of<GlobalNotifier>(context, listen: false).playing !=
                index) {
          // _controller.play();
          Provider.of<GlobalNotifier>(context, listen: false).setPlaying(index);
          Provider.of<GlobalNotifier>(context, listen: false)
              .setPlayingState(true);
        } else {
          Provider.of<GlobalNotifier>(context, listen: false).setPlaying(index);
          // _controller.pause();
          Provider.of<GlobalNotifier>(context, listen: false)
              .setPlayingState(false);
        }
      },
      style: TextButton.styleFrom(
        primary: Config.colorStyle,
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        children: [
          // SizedBox(
          //   height: 40,
          //   width: 40,
          //   child: AbsorbPointer(
          //     child: YoutubePlayerIFrame(
          //       // liveUIColor: Config.colorStyle,
          //       // width: 40,
          //       controller: _controller,
          //       // i think this is how you ignore the pointer somehow
          //       // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          //       //   Factory<OneSequenceGestureRecognizer>(
          //       //     () => EagerGestureRecognizer(),
          //       //   ),
          //       // },
          //     ),
          //   ),
          // ),
          Image.network(
            snapshot.data!.docs.toList()[index].data()['icon'],
            height: 40,
            width: 40,
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
              Text(
                snapshot.data!.docs.toList()[index].data()['track'],
                textScaleFactor: 1.25,
                style: index ==
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .playing // not working to listen?
                    ? const TextStyle(
                        color: Config.colorStyle1, overflow: TextOverflow.clip)
                    : const TextStyle(
                        color: Color.fromARGB(200, 255, 255, 255),
                        overflow: TextOverflow.clip,
                      ),
              ), // LIVE DATA UPDATE
              const SizedBox(height: 5),
            ],
          ),
        ],
      ),
    ),
  );
}
