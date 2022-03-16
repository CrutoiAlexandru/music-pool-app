// music platform buttons builder methods
// needs to contain search bar to search songs on each platform
// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../config.dart';

// method for spotify button
// TextButton spotifyButton(BuildContext context) {
Widget spotifyButton(BuildContext context) {
  String input = '';

  Future<void> addData() async {
    final songslist = FirebaseFirestore.instance.collection(
        'song_list'); // NEEDS THE CODE OF THE SESSION, EACH SESH WILL BE THE DIRECTORY
    // ADD ACTUAL TRACK DATA RECOVERED FROM MUSCI PLATFORM
    return songslist
        .add({
          'track': 'rap god',
          'artist': 'eminem',
        })
        .then((value) => print('Added song'))
        .catchError((error) => print("Failed to add data: $error"));
  }

  void isEntered() async {
    final res = await LiveSpotifyController().search(input);
    print(res);
    addData();
    Navigator.pop(context, 'Add song');
  }

  return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.white,
        elevation: 1,
      ),
      onPressed: () => LiveSpotifyController.connected == false
          ? showDialog(
              context: context,
              builder: (BuildContext context) => const AlertDialog(
                  title: Text('You are not logged in to Spotify!')))
          : showDialog(
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
                            maxLength: 20,
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
        Icons.ac_unit,
        color: Config.colorStyle,
        size: 40,
      ));
}

// method for soundcloud button
Widget soundcloudButton(BuildContext context) {
  String input = '';

  void isEntered() async {
    final res =
        await LiveSpotifyController().search(input); // change to soundcloud
    print(res);
    Navigator.pop(context, 'Add song');
  }

  return TextButton(
    style: TextButton.styleFrom(
      primary: Colors.white,
      elevation: 1,
    ),
    onPressed: () => LiveSpotifyController.connected == false
        ? showDialog(
            context: context,
            builder: (BuildContext context) => const AlertDialog(
                title: Text(
                    'You are not logged in to SoundCloud!'))) // TO BE SOUNDCLOUD CONTROLLER
        : showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text(
                    'SoundCloud',
                    style: TextStyle(color: Config.colorStyle),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                            'This is where you add songs from SoundCloud'),
                        TextField(
                          maxLength: 20,
                          autofocus: true,
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
      Icons.ac_unit,
      color: Config.colorStyle,
      size: 40,
    ),
  );
}

// method for both buttons
Widget sliverToBoxAdapter(BuildContext context) {
  return SizedBox(
    height: 50.0,
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      spotifyButton(context),
      soundcloudButton(context),
    ]),
  );
}
