// music platform buttons builder methods
// needs to contain search bar to search songs on each platform
// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:html';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/ui/config.dart';

class AddSongButton extends StatefulWidget {
  const AddSongButton({Key? key}) : super(key: key);

  @override
  State<AddSongButton> createState() => _AddSongButton();
}

class _AddSongButton extends State<AddSongButton> {
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
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Config.colorStyle1),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              backgroundColor: Config.back2,
              title: const Text(
                'Add a song from your favorite platform',
                style: TextStyle(color: Config.colorStyle1),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          minimumSize: const Size(double.maxFinite, 0),
                          primary: Colors.white,
                          backgroundColor: Provider.of<GlobalNotifier>(context)
                                      .platform
                                      .toLowerCase() ==
                                  'spotify'
                              ? Config.colorStyle1
                              : Config.colorStyle2),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Config.colorStyle1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          backgroundColor: Config.back2,
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                      minimumSize:
                                          const Size(double.maxFinite, 0),
                                      primary: Colors.white,
                                      backgroundColor: Config.colorStyle1),
                                  onPressed: () {
                                    Provider.of<GlobalNotifier>(context,
                                            listen: false)
                                        .setPlatform('Spotify');
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Spotify',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      minimumSize:
                                          const Size(double.maxFinite, 0),
                                      primary: Colors.white,
                                      backgroundColor: Config.colorStyle2),
                                  onPressed: () {
                                    Provider.of<GlobalNotifier>(context,
                                            listen: false)
                                        .setPlatform('SoundCloud');
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'SoundCloud',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      child: Text(
                        Provider.of<GlobalNotifier>(context).platform,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      autofocus: true,
                      maxLength: 50,
                      onChanged: (text) {
                        input = text;
                      },
                      onEditingComplete: isEntered,
                      cursorColor: Config.colorStyle1,
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Config.colorStyle1)),
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
                      backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      elevation: 2,
                      backgroundColor: Config.colorStyle1),
                  onPressed: isEntered,
                  child: const Text('Add song'),
                ),
              ],
            ),
          ),
          child: const Icon(
            Icons.add,
            color: Config.colorStyle1,
            size: 40,
          ),
        )
      ],
    );
  }

  Future<void> addData(String artist, String name, String playbackUri,
      String icon, String platform) async {
    // if playlist has objects get the last object order
    // if we set to order by order and the id to order it somehow fixes the order in the db?
    if (Provider.of<GlobalNotifier>(context, listen: false).playlistSize > 0) {
      var aux = await songslist.orderBy('order').get();
      var lastId = await aux.docs[
          Provider.of<GlobalNotifier>(context, listen: false).playlistSize - 1];
      Provider.of<GlobalNotifier>(context, listen: false)
          .setOrder(lastId['order']);
    }

    // increment the last order
    Provider.of<GlobalNotifier>(context, listen: false).setOrder(
        Provider.of<GlobalNotifier>(context, listen: false).order + 1);

    // set another object with the id^
    // we do this in order to keep the objects in order inside our firestore
    songslist
        .doc(Provider.of<GlobalNotifier>(context, listen: false)
            .order
            .toString())
        .set({
          'track': name,
          'artist': artist,
          'playback_uri': playbackUri,
          'icon': icon,
          'platform': platform,
          'order': Provider.of<GlobalNotifier>(context, listen: false).order
        })
        .then((value) => print('Added song'))
        .catchError((error) => print("Failed to add data: $error"));
  }

  void isEntered() async {
    if (input.isEmpty) {
      print('No input');
      return;
    }

    if (session == 'default') {
      print('no session');
      return;
    }

    if (Provider.of<GlobalNotifier>(context, listen: false)
            .platform
            .toLowerCase() ==
        'spotify') {
      final res = await LiveSpotifyController().search(input);

      final json = jsonDecode(res);
      print(res);
      addData(
        json['tracks']['items'][0]['artists'][0]['name'],
        json['tracks']['items'][0]['name'],
        json['tracks']['items'][0]['uri'],
        json['tracks']['items'][0]['album']['images'][0]['url'],
        Provider.of<GlobalNotifier>(context, listen: false)
            .platform
            .toLowerCase(),
      );
    }

    input = '';

    Navigator.pop(context, 'Add song');
  }
}

class MusicAddButtons extends StatelessWidget {
  const MusicAddButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AddSongButton();
  }
}
