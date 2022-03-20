// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../.config_for_app.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;

// WEB ONLY LIBRARIES MUST BE REMOVED BEFORE ANDROID BUILD
// import 'dart:js' as js;

class SpotifyController extends StatefulWidget {
  const SpotifyController({Key? key}) : super(key: key);

  @override
  LiveSpotifyController createState() => LiveSpotifyController();
}

class LiveSpotifyController extends State<SpotifyController> {
  bool _loading = false;
  static bool connected = false;
  final endpoint = 'accounts.spotify.com';
  static const redirectUrl = 'https://music-pool-app-50127.web.app/auth.html';
  static String token = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: connected
              ? const Text('Log out of Spotify')
              : const Text('Log in to Spotify'),
          onTap: connected
              ? disconnect
              : () async {
                  token = await auth();
                  setState(() {});
                },
        ),
        TextButton(onPressed: play, child: const Text('PLAY')),
        // LOGIN AND CONNECT TO REMOTE WILL BE THE SAME BUTTON
        // LOGIN NEEDED FOR TOKEN AND DATA REQUESTS
        // REMOTE FOR PLAYBACK
        TextButton(
            onPressed: () async {
              token = await auth();
              if (token.isNotEmpty) {
                if (kIsWeb) {
                  // js.context.callMethod('logger', [token]);
                } else {
                  connectToSpotifyRemote();
                }
              }
            },
            child: const Text('CONNECT')),
      ],
    );
  }

  // Widget _buildPlayerStateWidget() {
  //   return StreamBuilder<PlayerState>(
  //     stream: SpotifySdk.subscribePlayerState(),
  //     builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
  //       var track = snapshot.data?.track;
  //       var playerState = snapshot.data;

  //       if (playerState == null || track == null) {
  //         return Center(
  //           child: Container(),
  //         );
  //       }

  //       return const Text("yesman");
  //     },
  //   );
  // }

  // Widget _buildPlayerContextWidget() {
  //   return StreamBuilder<PlayerContext>(
  //     stream: SpotifySdk.subscribePlayerContext(),
  //     initialData: PlayerContext('', '', '', ''),
  //     builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
  //       var playerContext = snapshot.data;
  //       if (playerContext == null) {
  //         return const Center(
  //           child: Text('Not connected'),
  //         );
  //       }

  //       return Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           Text('Title: ${playerContext.title}'),
  //           Text('Subtitle: ${playerContext.subtitle}'),
  //           Text('Type: ${playerContext.type}'),
  //           Text('Uri: ${playerContext.uri}'),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<String> search(song) async {
    var url = Uri.https('api.spotify.com', '/v1/search', {
      'q': song,
      'type': ['track'],
      'limit': '1',
    });
    final res =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});
    return res.body.toString();
  }

  static Future<String> auth() async {
    try {
      // GET AUTH TOKEN THROUGH SERVER SIDE REQUEST
      // NEED TO ALSO RECEIVE REFRESH TOKEN AND EXPIRE TIME, JS?
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
        clientId: SpotifyConfig.clientID,
        redirectUrl: redirectUrl,
        // scope: 'app-remote-control, '
        //     'user-modify-playback-state, '
        //     'playlist-read-private, '
        //     'playlist-modify-public,user-read-currently-playing',
        scope: 'streaming, '
            'user-read-email, '
            'user-read-private, '
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

  // void createWebPlayer() {
  //   player = Player(
  //     PlayerOptions(
  //         name: 'WebPlayer',
  //         getOAuthToken: () {
  //           return token;
  //         },
  //         volume: 100),
  //   );
  //   // player.addListener(token, () {});
  //   player.connect();
  // }

  Future<void> connectToSpotifyRemote() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: SpotifyConfig.clientID,
        redirectUrl: redirectUrl,
        accessToken: token,
      );
      print(result);
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  Future<void> disconnect() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.disconnect();
      setState(() {
        token = '';
        connected = false;
        _loading = false;
      });
      setStatus(result ? 'disconnect successful' : 'disconnect failed');
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  Future<void> play() async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:track:4bdEXTweGw1O4IEMbnn5Tv');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> stop() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    print('$code$text');
  }
}
