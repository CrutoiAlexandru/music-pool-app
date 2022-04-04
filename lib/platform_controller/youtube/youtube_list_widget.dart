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
Widget listItemYT(snapshot, context, index) {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: snapshot.data!.docs.toList()[index].data()['playback_uri'],
    // flags: const YoutubePlayerFlags(
    params: const YoutubePlayerParams(
      autoPlay: false,
      // hideControls: true,
      showControls: false,
      loop: false,
      // controlsVisibleAtStart: false,
      showFullscreenButton: false,
      showVideoAnnotations: false,
      // hideThumbnail: true,
    ),
  );

  return Container(
    color: Colors.transparent,
    margin: const EdgeInsets.only(top: 10),
    child: TextButton(
      onPressed: () {
        if (!Provider.of<GlobalNotifier>(context, listen: false).playState ||
            Provider.of<GlobalNotifier>(context, listen: false).playing !=
                index) {
          if (Provider.of<GlobalNotifier>(context, listen: false).playing ==
              index) {
            _controller.play();
          } else {
            _controller.play();
          }
          Provider.of<GlobalNotifier>(context, listen: false).setPlaying(index);

          Provider.of<GlobalNotifier>(context, listen: false)
              .setPlayingState(true);
        } else {
          Provider.of<GlobalNotifier>(context, listen: false).setPlaying(index);
          _controller.pause();
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
          SizedBox(
            height: 40,
            width: 40,
            child: AbsorbPointer(
              child: YoutubePlayerIFrame(
                // liveUIColor: Config.colorStyle,
                // width: 40,
                controller: _controller,
                // i think this is how you ignore the pointer somehow
                // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                //   Factory<OneSequenceGestureRecognizer>(
                //     () => EagerGestureRecognizer(),
                //   ),
                // },
              ),
            ),
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
              SizedBox(height: 5),
            ],
          ),
        ],
      ),
    ),
  );
}
