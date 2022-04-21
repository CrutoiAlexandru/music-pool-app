import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:music_pool_app/.config_for_app.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;

// WEB ONLY LIBRARIES MUST BE REMOVED BEFORE ANDROID BUILD
import 'package:spotify_sdk/spotify_sdk_web.dart';

// class that handles all methods concerning spotify: connection, audio playback, data receiving
class SpotifyController {
  // boolean for knowing if we connected to spotify
  static bool connectedSpotify = false;
  // String for the spotify endpoint
  static String endpoint = 'accounts.spotify.com';
  // String for our specific redirect uri that points us back to our app when the login is over
  static String redirectUrl = 'https://music-pool-app-50127.web.app/auth.html';
  // String for out spotify token used to transactions with spotify
  static String token = '';
  // player, more specifically used for creating the web player(different from the android player which is the app installed on the mobile)
  static late Player player;

  // method for searching for an audio
  // retrieve first 5 audio results
  static Future<String> search(audio) async {
    var url = Uri.https('api.spotify.com', '/v1/search', {
      'q': audio,
      'type': ['track'],
      'limit': '5',
    });
    final res =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});
    return res.body.toString();
  }

  // method for seeking to a specific position in the audio
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

  // method for authenticating with an oauth2 flow
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
      connectedSpotify = true;
      if (kDebugMode) {
        print('Got token: $authenticationToken');
      }
      return authenticationToken;
    } on PlatformException catch (e) {
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      return Future.error('not implemented');
    }
  }

  // ONLY ON WEB, DISABLE FOR ANDROID BUILD
  // method for creating the web player(on web only)
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
      if (kDebugMode) {
        print("Device ID has gone offline $e");
      }
    });

    player.addListener("initialization_error", (message) {
      if (kDebugMode) {
        print(message);
      }
    });

    player.addListener("authentication_error", (message) {
      if (kDebugMode) {
        print(message);
      }
    });

    player.addListener("account_error", (message) {
      if (kDebugMode) {
        print(message);
      }
    });

    player.connect();
  }

  // method for connecting to the spotify application on the user's mobile
  // this is the equivalent of the web player but on mobile
  // the only way of playing audio on mobile
  static Future<void> connectToSpotifyRemote() async {
    try {
      var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: SpotifyConfig.clientID,
        redirectUrl: redirectUrl,
        accessToken: token,
      );
      if (kDebugMode) {
        print(result);
      }
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  // method for disconnecting the user from spotify
  static Future<void> disconnect() async {
    token = '';
    connectedSpotify = false;
  }

  // method for playing the audio
  static Future<void> play(String spotifyUri) async {
    try {
      await SpotifySdk.play(spotifyUri: spotifyUri);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  // method for pausing the audio
  static Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  // method for resuming the audio
  // different than play, play starts the audio from 0
  static Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  // method for retrieving the current state of our audio player
  // paused or playing
  static Future getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  // testing method
  static void setStatus(String code, {String? message}) {
    var text = message ?? '';
    if (kDebugMode) {
      print('$code$text');
    }
  }
}
