// ignore_for_file: , avoid_web_libraries_in_flutter, prefer_typing_uninitialized_variables
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';
import 'package:music_pool_app/.config_for_app.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;

// WEB ONLY LIBRARIES MUST BE REMOVED BEFORE ANDROID BUILD
import 'dart:js' as js;
import 'package:spotify_sdk/spotify_sdk_web.dart';

class PlatformController extends StatefulWidget {
  const PlatformController({Key? key}) : super(key: key);

  @override
  State<PlatformController> createState() => _PlatformController();
}

// NEED TO MAKE ONE CONTROLLER FOR MULTIPLE PLATFORMS
// AND ONE EACH WITH SPECIFIC CONTROLS
class _PlatformController extends State<PlatformController> {
  // static bool connected = false;
  // final endpoint = 'accounts.spotify.com';
  // static const redirectUrl = 'https://music-pool-app-50127.web.app/auth.html';
  // static String token = '';
  // var player;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          style: !SpotifyController.connected
              ? TextButton.styleFrom(
                  minimumSize: const Size(280, 40),
                  backgroundColor: Config.colorStyle,
                )
              : TextButton.styleFrom(
                  minimumSize: const Size(280, 40),
                  backgroundColor: Config.colorStyle2,
                ),
          child: SpotifyController.connected
              ? const Text(
                  'Log out',
                  style: TextStyle(
                    color: Config.back1,
                    fontSize: 15,
                  ),
                )
              : const Text(
                  'Log in',
                  style: TextStyle(
                    color: Config.back1,
                    fontSize: 15,
                  ),
                ),
          onPressed: SpotifyController.connected
              ? () {
                  // open disconnect medium for multiple platforms
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Config.colorStyle1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      backgroundColor: Config.back2,
                      title: const Center(
                        child: Text(
                          'Log out of these platforms',
                          style: TextStyle(color: Config.colorStyle1),
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(width: double.maxFinite),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Config.colorStyle1,
                                  ),
                                  onPressed: () async {
                                    // SPOTIFY DISCONNECT MEDIUM
                                    SpotifyController.disconnect();
                                    Provider.of<GlobalNotifier>(context,
                                            listen: false)
                                        .setConnection(
                                            SpotifyController.connected);
                                    SpotifyController.pause();
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Log out of Spotify',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Config.colorStyle2,
                                  ),
                                  onPressed: () async {
                                    // SOUNDCLOUD DISCONNECT MEDIUM

                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Log out of SoundCloud',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              : () async {
                  // open second window to connect to multiple platforms
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Config.colorStyle1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      backgroundColor: Config.back2,
                      title: const Center(
                        child: Text(
                          'Log in to your favorite platforms',
                          style: TextStyle(color: Config.colorStyle1),
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(width: double.maxFinite),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Config.colorStyle1,
                                  ),
                                  onPressed: () async {
                                    // SPOTIFY AUTH MEDIUM
                                    SpotifyController.token =
                                        await SpotifyController.auth();
                                    if (SpotifyController.connected) {
                                      Provider.of<GlobalNotifier>(context,
                                              listen: false)
                                          .setConnection(
                                              SpotifyController.connected);
                                    }
                                    setState(() {});

                                    if (kIsWeb) {
                                      js.allowInterop(
                                          SpotifyController.createWebPlayer);
                                      SpotifyController
                                          .connectToSpotifyRemote();
                                    } else {
                                      SpotifyController
                                          .connectToSpotifyRemote();
                                    }

                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Log in to Spotify',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Config.colorStyle2,
                                  ),
                                  onPressed: () async {
                                    // SOUNDCLOUD AUTH MEDIUM
                                    // token = await auth();
                                    // if (connected) {
                                    //   Provider.of<GlobalNotifier>(context,
                                    //           listen: false)
                                    //       .setConnection(connected);
                                    // }
                                    // setState(() {});

                                    // if (kIsWeb) {
                                    //   // js.allowInterop(createWebPlayer);
                                    //   // connectToSpotifyRemote();
                                    // } else {
                                    //   connectToSpotifyRemote();
                                    // }
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Log in to SoundCloud',
                                    style: TextStyle(color: Colors.white),
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
