// music platform buttons builder methods
// needs to contain search bar to search songs on each platform
// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  var songsList;
  String session = 'default';
  var requiredSongList = <Map>[];

  @override
  void initState() {
    songsList = FirebaseFirestore.instance.collection('default');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<SessionNotifier>(context).session.isNotEmpty) {
      session = Provider.of<SessionNotifier>(context).session;
      songsList = FirebaseFirestore.instance
          .collection(Provider.of<SessionNotifier>(context).session);
    } else {
      session = 'default';
      songsList = FirebaseFirestore.instance.collection('default');
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
                physics: const ClampingScrollPhysics(),
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
                    // LIST TOP 5 SONG RESULTS
                    if (Provider.of<GlobalNotifier>(context)
                        .requiredSongList
                        .isNotEmpty)
                      SizedBox(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount: 5,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return listItem(
                                Provider.of<GlobalNotifier>(
                                  context,
                                ).requiredSongList,
                                context,
                                index);
                          },
                        ),
                      )
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
                  child: const Text('Search'),
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
      var aux = await songsList.orderBy('order').get();
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
    songsList
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

      // populate requiredSongList with top 5 songs
      // list has also 5 items
      for (int i = 0; i < 5; i++) {
        requiredSongList.add(
          {
            'track': json['tracks']['items'][i]['artists'][0]['name'],
            'artist': json['tracks']['items'][i]['name'],
            'playback_uri': json['tracks']['items'][i]['uri'],
            'icon': json['tracks']['items'][i]['album']['images'][0]['url'],
            'platform': Provider.of<GlobalNotifier>(context, listen: false)
                .platform
                .toLowerCase(),
          },
        );
      }

      Provider.of<GlobalNotifier>(context, listen: false)
          .setRequiredSongList(requiredSongList);

      setState(() {
        requiredSongList.clear();
      });
    }
  }

  Widget listItem(snapshot, context, index) {
    return Container(
      height: 50,
      color: Colors.transparent,
      margin: const EdgeInsets.only(top: 10),
      child: TextButton(
        onPressed: () {
          addData(
              snapshot[index]['artist'],
              snapshot[index]['track'],
              snapshot[index]['playback_uri'],
              snapshot[index]['icon'],
              snapshot[index]['platform']);
          Provider.of<GlobalNotifier>(context, listen: false)
              .clearRequiredSongList();
          Navigator.pop(context);
        },
        style: TextButton.styleFrom(
          primary: Colors.white,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        child: Row(
          children: [
            if (kIsWeb)
              Image.network(
                snapshot[index]['icon'],
                height: 40,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot[index]['track'],
                  textScaleFactor: 1.25,
                  style: index == Provider.of<GlobalNotifier>(context).playing
                      ? snapshot[index]['platform'] == 'spotify'
                          ? const TextStyle(
                              color: Config.colorStyle1,
                              overflow: TextOverflow.clip)
                          : const TextStyle(
                              color: Config.colorStyle2,
                              overflow: TextOverflow.clip)
                      : const TextStyle(
                          color: Color.fromARGB(200, 255, 255, 255),
                          overflow: TextOverflow.clip,
                        ),
                ),
                const SizedBox(height: 5),
                Text(
                  snapshot[index]['artist'],
                  textScaleFactor: 0.9,
                  style: index == Provider.of<GlobalNotifier>(context).playing
                      ? snapshot[index]['platform'] == 'spotify'
                          ? const TextStyle(color: Config.colorStyle1Dark)
                          : const TextStyle(color: Config.colorStyle2Dark)
                      : const TextStyle(
                          color: Color.fromARGB(150, 255, 255, 255),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MusicAddButtons extends StatelessWidget {
  const MusicAddButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AddSongButton();
  }
}
