import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/platform_controller/spotify/spotify_controller.dart';
import 'package:music_pool_app/platform_controller/youtube/youtube_controller.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';

// WEB ONLY LIBRARIES MUST BE REMOVED BEFORE ANDROID BUILD
import 'dart:js' as js;

// class designed for logging in on a platform and logging out of a platform
class PlatformController extends StatefulWidget {
  const PlatformController({Key? key}) : super(key: key);

  @override
  State<PlatformController> createState() => _PlatformController();
}

class _PlatformController extends State<PlatformController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          style: TextButton.styleFrom(
            primary: Config.colorStyle,
            minimumSize: const Size(280, 40),
            backgroundColor: Config.colorStyle,
          ),
          child: const Text(
            'Log in',
            style: TextStyle(
              color: Config.back2,
              fontSize: 15,
            ),
          ),
          onPressed: () async {
            // open second window to connect to multiple platforms
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Config.colorStyle),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                backgroundColor: Config.back2,
                title: const Center(
                  child: Text(
                    'Log in to your favorite platforms',
                    style: TextStyle(color: Config.colorStyle),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(width: double.maxFinite),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: Config.colorStyle,
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () async {
                                // Spotify AUTH MEDIUM
                                SpotifyController.token =
                                    await SpotifyController.auth();
                                if (SpotifyController.connectedSpotify) {
                                  Provider.of<GlobalNotifier>(context,
                                          listen: false)
                                      .setSpotifyConnection(
                                          SpotifyController.connectedSpotify);
                                }
                                setState(() {});

                                // ONLY FOR WEB, DISABLE FOR ANDROID BUILD
                                // either create a web player for web or connect to the spotify app on mobile
                                if (kIsWeb) {
                                  js.allowInterop(
                                      SpotifyController.createWebPlayer);
                                  SpotifyController.connectToSpotifyRemote();
                                } else {
                                  SpotifyController.connectToSpotifyRemote();
                                }

                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Spotify',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: Config.colorStyle,
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () async {
                                // YouTube AUTH MEDIUM
                                await YoutubeController.apiConnect();
                                Provider.of<GlobalNotifier>(context,
                                        listen: false)
                                    .setYouTubeConnection(true);

                                Navigator.pop(context);
                              },
                              child: const Text(
                                'YouTube',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (Provider.of<GlobalNotifier>(context).connectedSpotify ||
            Provider.of<GlobalNotifier>(context).connectedYouTube)
          TextButton(
            style: TextButton.styleFrom(
              primary: Config.colorStyle,
              minimumSize: const Size(280, 40),
              backgroundColor: Config.colorStyleOposite,
            ),
            child: const Text(
              'Log out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            onPressed: () {
              // open disconnect medium for multiple platforms
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Config.colorStyle),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  backgroundColor: Config.back2,
                  title: const Center(
                    child: Text(
                      'Log out of these platforms',
                      style: TextStyle(color: Config.colorStyle),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(width: double.maxFinite),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  primary: Config.colorStyle,
                                  backgroundColor: Colors.transparent,
                                ),
                                onPressed: () async {
                                  // Spotify DISCONNECT MEDIUM
                                  SpotifyController.disconnect();
                                  Provider.of<GlobalNotifier>(context,
                                          listen: false)
                                      .setSpotifyConnection(
                                          SpotifyController.connectedSpotify);
                                  SpotifyController.pause();
                                  setState(() {});

                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Spotify',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  primary: Config.colorStyle,
                                  backgroundColor: Colors.transparent,
                                ),
                                onPressed: () async {
                                  // YouTube DISCONNECT MEDIUM
                                  await YoutubeController.apiDisconnect();
                                  Provider.of<GlobalNotifier>(context,
                                          listen: false)
                                      .setYouTubeConnection(false);
                                  setState(() {});

                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'YouTube',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        if (kIsWeb) const SizedBox(height: 10),
      ],
    );
  }
}
