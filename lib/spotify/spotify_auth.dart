// ignore_for_file: import_of_legacy_library_into_null_safe
// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import '../.config_for_app.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyAuth {
  final endpoint = 'accounts.spotify.com';
  final redirectURI = 'https://music-pool-app-50127.web.app/auth.html';
  // final redirectURI = 'http://localhost:8888/auth.html';

  Future<String> auth() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId: SpotifyConfig.clientID,
          redirectUrl: redirectURI,
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      setStatus('Got a token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    print('$code$text');
  }
}
