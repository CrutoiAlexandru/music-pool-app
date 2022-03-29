// ignore_for_file: , avoid_web_libraries_in_flutter, prefer_typing_uninitialized_variables
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';
import 'package:music_pool_app/.config_for_app.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;

// WEB ONLY LIBRARIES MUST BE REMOVED BEFORE ANDROID BUILD
import 'dart:js' as js;
import 'package:spotify_sdk/spotify_sdk_web.dart';

// class SpotifyController extends StatefulWidget {
//   const SpotifyController({Key? key}) : super(key: key);

//   @override
//   SpotifyController createState() => SpotifyController();
// }

// NEED TO MAKE ONE CONTROLLER FOR MULTIPLE PLATFORMS
// AND ONE EACH WITH SPECIFIC CONTROLS
class SpotifyController {
  //extends State<SpotifyController> {
  static bool connected = false;
  static const endpoint = 'accounts.spotify.com';
  static const redirectUrl = 'https://music-pool-app-50127.web.app/auth.html';
  static String token = '';
  static var player;

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       TextButton(
  //         style: !connected
  //             ? TextButton.styleFrom(
  //                 minimumSize: const Size(280, 40),
  //                 backgroundColor: Config.colorStyle,
  //               )
  //             : TextButton.styleFrom(
  //                 minimumSize: const Size(280, 40),
  //                 backgroundColor: Config.colorStyle2,
  //               ),
  //         child: connected
  //             ? const Text(
  //                 'Log out',
  //                 style: TextStyle(
  //                   color: Config.back1,
  //                   fontSize: 15,
  //                 ),
  //               )
  //             : const Text(
  //                 'Log in',
  //                 style: TextStyle(
  //                   color: Config.back1,
  //                   fontSize: 15,
  //                 ),
  //               ),
  //         onPressed: connected
  //             ? () {
  //                 // open disconnect medium for multiple platforms
  //                 showDialog(
  //                   context: context,
  //                   builder: (BuildContext context) => AlertDialog(
  //                     shape: const RoundedRectangleBorder(
  //                       side: BorderSide(color: Config.colorStyle1),
  //                       borderRadius: BorderRadius.all(
  //                         Radius.circular(10),
  //                       ),
  //                     ),
  //                     backgroundColor: Config.back2,
  //                     title: const Text(
  //                       'Log out of these platforms',
  //                       style: TextStyle(color: Config.colorStyle1),
  //                     ),
  //                     content: SingleChildScrollView(
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           TextButton(
  //                             style: TextButton.styleFrom(
  //                               primary: Colors.white,
  //                               backgroundColor: Config.colorStyle1,
  //                             ),
  //                             onPressed: () async {
  //                               // SPOTIFY DISCONNECT MEDIUM
  //                               disconnect();
  //                               Provider.of<GlobalNotifier>(context,
  //                                       listen: false)
  //                                   .setConnection(connected);
  //                               SpotifyController.pause();

  //                               Navigator.pop(context);
  //                             },
  //                             child: const Text(
  //                               'Log out of Spotify',
  //                               style: TextStyle(color: Colors.white),
  //                             ),
  //                           ),
  //                           TextButton(
  //                             style: TextButton.styleFrom(
  //                               primary: Colors.white,
  //                               backgroundColor: Config.colorStyle2,
  //                             ),
  //                             onPressed: () async {
  //                               // SOUNDCLOUD DISCONNECT MEDIUM

  //                               Navigator.pop(context);
  //                             },
  //                             child: const Text(
  //                               'Log out of SoundCloud',
  //                               style: TextStyle(color: Colors.white),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               }
  //             : () async {
  //                 // open second window to connect to multiple platforms
  //                 showDialog(
  //                   context: context,
  //                   builder: (BuildContext context) => AlertDialog(
  //                     shape: const RoundedRectangleBorder(
  //                       side: BorderSide(color: Config.colorStyle1),
  //                       borderRadius: BorderRadius.all(
  //                         Radius.circular(10),
  //                       ),
  //                     ),
  //                     backgroundColor: Config.back2,
  //                     title: const Text(
  //                       'Log in to your favorite platforms',
  //                       style: TextStyle(color: Config.colorStyle1),
  //                     ),
  //                     content: SingleChildScrollView(
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: [
  //                           TextButton(
  //                             style: TextButton.styleFrom(
  //                               primary: Colors.white,
  //                               backgroundColor: Config.colorStyle1,
  //                             ),
  //                             onPressed: () async {
  //                               // SPOTIFY AUTH MEDIUM
  //                               token = await auth();
  //                               if (connected) {
  //                                 Provider.of<GlobalNotifier>(context,
  //                                         listen: false)
  //                                     .setConnection(connected);
  //                               }
  //                               setState(() {});

  //                               if (kIsWeb) {
  //                                 js.allowInterop(createWebPlayer);
  //                                 connectToSpotifyRemote();
  //                               } else {
  //                                 connectToSpotifyRemote();
  //                               }

  //                               Navigator.pop(context);
  //                             },
  //                             child: const Text(
  //                               'Log in to Spotify',
  //                               style: TextStyle(color: Colors.white),
  //                             ),
  //                           ),
  //                           TextButton(
  //                             style: TextButton.styleFrom(
  //                               primary: Colors.white,
  //                               backgroundColor: Config.colorStyle2,
  //                             ),
  //                             onPressed: () async {
  //                               // SOUNDCLOUD AUTH MEDIUM
  //                               // token = await auth();
  //                               // if (connected) {
  //                               //   Provider.of<GlobalNotifier>(context,
  //                               //           listen: false)
  //                               //       .setConnection(connected);
  //                               // }
  //                               // setState(() {});

  //                               // if (kIsWeb) {
  //                               //   // js.allowInterop(createWebPlayer);
  //                               //   // connectToSpotifyRemote();
  //                               // } else {
  //                               //   connectToSpotifyRemote();
  //                               // }
  //                               Navigator.pop(context);
  //                             },
  //                             child: const Text(
  //                               'Log in to SoundCloud',
  //                               style: TextStyle(color: Colors.white),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               },
  //       ),
  //       if (kIsWeb) const SizedBox(height: 10),
  //     ],
  //   );
  // }

  static Future<String> search(song) async {
    var url = Uri.https('api.spotify.com', '/v1/search', {
      'q': song,
      'type': ['track'],
      'limit': '5',
    });
    final res =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});
    return res.body.toString();
  }

  static Future<void> seekTo(position) async {
    try {
      var url = Uri.https('api.spotify.com', '/v1/me/player/seek', {
        'position_ms': '${(position / 1000).floor()}',
      });
      await http.put(url, headers: {'Authorization': 'Bearer $token'});
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  static Future<String> auth() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
        clientId: SpotifyConfig.clientID,
        redirectUrl: redirectUrl,
        scope: 'streaming, '
            'app-remote-control, '
            'user-read-email, '
            'user-read-private, '
            'playlist-read-private, '
            'playlist-modify-public, '
            'user-read-currently-playing, '
            'user-read-playback-state, '
            'user-modify-playback-state',
      );
      connected = true;
      print('Got token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      return Future.error('not implemented');
    }
  }

  static void createWebPlayer() {
    player = Player(
      PlayerOptions(
          name: 'WebPlayer',
          getOAuthToken: (cb) {
            cb(token);
          },
          volume: 30),
    );

    player.addListener("not_ready", (e) {
      print("Device ID has gone offline $e");
    });

    player.addListener("initialization_error", (message) {
      print(message);
    });

    player.addListener("authentication_error", (message) {
      print(message);
    });

    player.addListener("account_error", (message) {
      print(message);
    });

    player.connect();
  }

  static Future<void> connectToSpotifyRemote() async {
    try {
      var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: SpotifyConfig.clientID,
        redirectUrl: redirectUrl,
        accessToken: token,
      );
      print(result);
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  static Future<void> disconnect() async {
    token = '';
    connected = false;
  }

  static Future<void> play(String spotifyUri) async {
    try {
      await SpotifySdk.play(spotifyUri: spotifyUri);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  static Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  static Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  static Future getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  static void setStatus(String code, {String? message}) {
    var text = message ?? '';
    print('$code$text');
  }
}
