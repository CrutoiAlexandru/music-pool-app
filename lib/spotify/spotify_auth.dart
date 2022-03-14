// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import '.spotify_config.dart';

class SpotifyAuth {
  final endpoint = 'accounts.spotify.com';
  // final redirectURI = 'https://github.com/CrutoiAlexandru';
  // final redirectURI = 'https://music-pool-app-50127.web.app/#/';
  final redirectURI = 'http://localhost:8888/#/';

  Future<void> getToken() async {
    var r;
    var url = Uri.https(endpoint, '/authorize', {
      'response_type': 'code',
      'client_id': SpotifyConfig.clientID,
      'redirect_uri': redirectURI,
      'show_dialog': 'true'
    });

    print('#####################AUTH############################');

    try {
      r = FlutterWebAuth.authenticate(
          url: url.toString(), callbackUrlScheme: redirectURI);
    } on PlatformException catch (e) {
      r = "nope";
    }

    print(r);
  }
}
