import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayer extends StatefulWidget {
  const YoutubePlayer({Key? key}) : super(key: key);

  @override
  State<YoutubePlayer> createState() => _YoutubePlayer();
}

class _YoutubePlayer extends State<YoutubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = YoutubePlayerController(
      initialVideoId: 'znQriFAMBRs',
      params: const YoutubePlayerParams(
        loop: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Config.back2,
      height: 50,
      width: 100,
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
          child: YoutubePlayerIFrame(
            controller: _controller,
          ),
        ),
      ),
    );
  }
}
