import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatefulWidget {
  const YoutubePlayerWidget({Key? key}) : super(key: key);

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidget();
}

class _YoutubePlayerWidget extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = YoutubePlayerController(
      initialVideoId: 'znQriFAMBRs',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        hideControls: true,
        loop: false,
        controlsVisibleAtStart: false,
        hideThumbnail: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Config.back2,
      height: 50,
      child: TextButton(
        onPressed: () {
          if (Provider.of<GlobalNotifier>(context, listen: false).playState) {
            _controller.pause();
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(false);
          } else {
            _controller.play();
            Provider.of<GlobalNotifier>(context, listen: false)
                .setPlayingState(true);
          }
        },
        child: IgnorePointer(
          child: YoutubePlayer(
            liveUIColor: Config.colorStyle,
            width: 50,
            controller: _controller,
          ),
        ),
      ),
    );
  }
}

Widget listItemYT(context, index) {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'znQriFAMBRs',
    flags: const YoutubePlayerFlags(
      autoPlay: false,
      hideControls: true,
      loop: false,
      controlsVisibleAtStart: false,
      hideThumbnail: true,
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
          IgnorePointer(
            child: YoutubePlayer(
              liveUIColor: Config.colorStyle,
              width: 40,
              controller: _controller,
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
                'TITLE',
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
