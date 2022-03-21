// music platform buttons builder methods
// needs to contain search bar to search songs on each platform
// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/ui/config.dart';

class SpotifyButton extends StatefulWidget {
  const SpotifyButton({Key? key}) : super(key: key);

  @override
  State<SpotifyButton> createState() => _SpotifyButton();
}

// method for spotify button
// TextButton spotifyButton(BuildContext context) {
// Widget spotifyButton(BuildContext context) {
class _SpotifyButton extends State<SpotifyButton> {
  String input = '';
  var songslist;
  String session = 'default';

  @override
  void initState() {
    songslist = FirebaseFirestore.instance.collection('default');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<SessionNotifier>(context).session.isNotEmpty) {
      session = Provider.of<SessionNotifier>(context).session;
      songslist = FirebaseFirestore.instance
          .collection(Provider.of<SessionNotifier>(context).session);
    } else {
      session = 'default';
      songslist = FirebaseFirestore.instance.collection('default');
    }

    if (!Provider.of<GlobalNotifier>(context).connected) {
      return const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            elevation: 1,
          ),
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text(
                      'Spotify',
                      style: TextStyle(color: Config.colorStyle),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text(
                              'This is where you add songs from Spotify'),
                          TextField(
                            autofocus: true,
                            maxLength: 50,
                            onChanged: (text) {
                              input = text;
                            },
                            onEditingComplete: isEntered,
                            cursorColor: Config.colorStyle,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Config.colorStyle)),
                              border: OutlineInputBorder(),
                              hintText: 'Enter a song',
                            ),
                          ),
                          // maybe implement a list of songs found on the platform !?
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            elevation: 2,
                            backgroundColor: Config.colorStyle),
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            elevation: 2,
                            backgroundColor: Config.colorStyle),
                        onPressed: isEntered,
                        child: const Text('Add song'),
                      ),
                    ],
                  )),
          child: const Icon(
            Icons.add,
            color: Config.colorStyle,
            size: 40,
          ),
        )
      ],
    );
  }

  Future<void> addData(
      String artist, String name, String playbackUri, String icon) async {
    return songslist
        .add({
          'track': name,
          'artist': artist,
          'playback_uri': playbackUri,
          'icon': icon
        })
        .then((value) => print('Added song'))
        .catchError((error) => print("Failed to add data: $error"));
  }

  void isEntered() async {
    final res = await LiveSpotifyController().search(input);
    if (res.isEmpty) {
      print('No input');
      // print(songslist.docs());
      return;
    }
    if (session == 'default') {
      print('no session');
      return;
    }
    final json = jsonDecode(res);
    print(res);
    addData(
        json['tracks']['items'][0]['name'],
        json['tracks']['items'][0]['artists'][0]['name'],
        json['tracks']['items'][0]['uri'],
        json['tracks']['items'][0]['album']['images'][1]['url']);

    Navigator.pop(context, 'Add song');
  }
}

// method for both buttons
class MusicAddButtons extends StatelessWidget {
  const MusicAddButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          SpotifyButton(),
        ],
      ),
    );
  }
}
