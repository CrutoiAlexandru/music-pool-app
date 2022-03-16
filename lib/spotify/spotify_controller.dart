// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import '../.config_for_app.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class SpotifyController extends StatefulWidget {
  const SpotifyController({Key? key}) : super(key: key);

  @override
  LiveSpotifyController createState() => LiveSpotifyController();
}

class LiveSpotifyController extends State<SpotifyController> {
  bool _loading = false;
  static bool connected = false;
  final endpoint = 'accounts.spotify.com';
  final redirectURI = 'https://music-pool-app-50127.web.app/auth.html';
  static String token = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TextButton(onPressed: checkFire, child: const Text("FIRE")),
        TextButton(
          onPressed: () async {
            token = await auth();
          },
          child: const Text('login'),
        ),
        TextButton(
          onPressed: disconnect,
          child: const Text('logout'),
        ),
        StreamBuilder<ConnectionStatus>(
          stream: SpotifySdk.subscribeConnectionStatus(),
          builder: (context, snapshot) {
            return TextButton(
              onPressed: () {
                setStatus('Connection status: $connected');
              },
              child: const Text("Connection status"),
            );
          },
        ),
      ],
    );
  }

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

  Future<String> auth() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
        clientId: SpotifyConfig.clientID,
        redirectUrl: redirectURI,
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing',
      );
      setState(() {
        connected = true;
      });
      setStatus(
          'Got a token: $authenticationToken'); // DONT FORGET TO REMOVE THE TOKEN FROM THE CONSOLE WHEN LAUNCHING
      return authenticationToken;
    } on PlatformException catch (e) {
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
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

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    print('$code$text');
  }
}
