import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:MusicPool/global/global.dart';
import 'package:MusicPool/platform_controller/spotify/spotify_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:MusicPool/platform_controller/youtube/youtube_controller.dart';
import 'package:provider/provider.dart';
import 'package:MusicPool/global/session/session.dart';
import 'package:MusicPool/ui/config.dart';

// class that creates a button for adding music(audio/video) from Spotify or YouTube
// the user can first choose a platform
// the user can search for such audio source and retrieve live data on each type
// the user gets a list with top results from the platform chosen
// the user can add a certain audio source to the session queue by clicking the list item
class AddSongButton extends StatefulWidget {
  const AddSongButton({Key? key}) : super(key: key);

  @override
  State<AddSongButton> createState() => _AddSongButton();
}

class _AddSongButton extends State<AddSongButton> {
  // the input of the user(audio source search)
  String input = '';
  // collection reference for out Firestore data
  late CollectionReference database;
  // the session the user is in
  // if the user is in no session the default session is 'default'
  // this way we know when the user is in the default session to not add any songs
  String session = 'default';
  // the required audio list from a specific platform(top search results)
  List requiredSongList = <Map>[];

  @override
  void initState() {
    database = FirebaseFirestore.instance.collection('default');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // check if the user is in a session
    // if so create the database link
    if (Provider.of<SessionNotifier>(context).session.isNotEmpty) {
      session = Provider.of<SessionNotifier>(context).session;
      database = FirebaseFirestore.instance
          .collection(Provider.of<SessionNotifier>(context).session);
    } else {
      session = 'default';
      database = FirebaseFirestore.instance.collection('default');
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Config.back1,
            primary: Config.colorStyle,
            elevation: 1,
          ),
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Config.colorStyle),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              backgroundColor: Config.back2,
              title: const Text(
                'Add a song from your favorite platform',
                style: TextStyle(color: Config.colorStyle),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          minimumSize: const Size(double.maxFinite, 0),
                          primary: Config.colorStyle,
                          backgroundColor: Config.colorStyle),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Config.colorStyle),
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
                                      primary: Config.colorStyle,
                                      backgroundColor: Colors.transparent),
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
                                      primary: Config.colorStyle,
                                      backgroundColor: Colors.transparent),
                                  onPressed: () {
                                    Provider.of<GlobalNotifier>(context,
                                            listen: false)
                                        .setPlatform('YouTube');
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'YouTube',
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
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      autofocus: true,
                      maxLength: 50,
                      onChanged: (text) {
                        input = text;
                        isEntered();
                      },
                      cursorColor: Config.colorStyle,
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Config.colorStyle)),
                        border: OutlineInputBorder(),
                        hintText: 'Enter a song',
                      ),
                    ),
                    // LIST TOP SONG RESULTS
                    if (Provider.of<GlobalNotifier>(context)
                        .requiredSongList
                        .isNotEmpty)
                      SizedBox(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount: Provider.of<GlobalNotifier>(
                            context,
                          ).requiredSongList.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (Provider.of<GlobalNotifier>(context)
                                    .platform
                                    .toLowerCase() ==
                                'spotify') {
                              return listItemSpot(
                                  Provider.of<GlobalNotifier>(
                                    context,
                                  ).requiredSongList,
                                  context,
                                  index);
                            } else {
                              return listItemYT(
                                  Provider.of<GlobalNotifier>(
                                    context,
                                  ).requiredSongList,
                                  context,
                                  index);
                            }
                          },
                        ),
                      )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                      primary: Config.colorStyle,
                      backgroundColor: Config.colorStyleOpposite),
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          child: const Icon(
            Icons.add,
            color: Config.colorStyle,
            size: 40,
          ),
        )
      ],
    );
  }

  // same list widget made for local kept song list not from db
  // list item made for spotify
  Widget listItemSpot(snapshot, context, index) {
    return Container(
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
          primary: Config.colorStyle,
          backgroundColor: Colors.transparent,
        ),
        child: Row(
          children: [
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
                SizedBox(
                  width: kIsWeb
                      ? MediaQuery.of(context).size.width * 0.6
                      : MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    snapshot[index]['track'],
                    textScaleFactor: 1.25,
                    style: const TextStyle(
                      color: Color.fromARGB(200, 255, 255, 255),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  child: Text(
                    snapshot[index]['artist'],
                    textScaleFactor: 0.9,
                    style: const TextStyle(
                      color: Color.fromARGB(150, 255, 255, 255),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // same list widget made for local kept song list not from db
  // list item made for youtube
  Widget listItemYT(snapshot, context, index) {
    return Container(
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
          primary: Config.colorStyle,
          backgroundColor: Colors.transparent,
        ),
        child: Row(
          children: [
            Image.network(
              snapshot[index]['icon'],
              height: 40,
              width: 40,
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
                SizedBox(
                  width: kIsWeb
                      ? MediaQuery.of(context).size.width * 0.6
                      : MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    snapshot[index]['track'],
                    textScaleFactor: 1.25,
                    style: const TextStyle(
                      color: Color.fromARGB(200, 255, 255, 255),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // method for adding the specific song to our database
  // called only when the user selects a specific search results
  Future<void> addData(String artist, String name, String playbackUri,
      String icon, String platform) async {
    // if the user is in the default session we cannot add anything because there is nowhere to add to
    if (session == 'default') {
      if (kDebugMode) {
        print('no session');
      }
      // inform the user that he's not in a session
      return showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Config.colorStyle),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          backgroundColor: Config.back2,
          title: Text(
            'You are not in an actual session!',
            style: TextStyle(color: Config.colorStyle),
          ),
        ),
      );
    }
    // if playlist has objects get the last object order
    // if we set to order by order and the id to order it somehow fixes the order in the db?
    if (Provider.of<GlobalNotifier>(context, listen: false).playlistSize > 0) {
      var aux = await database.orderBy('order').get();
      var lastId = aux.docs[
          Provider.of<GlobalNotifier>(context, listen: false).playlistSize - 1];
      Provider.of<GlobalNotifier>(context, listen: false)
          .setOrder(lastId['order']);
    }

    // increment the last order
    Provider.of<GlobalNotifier>(context, listen: false).setOrder(
        Provider.of<GlobalNotifier>(context, listen: false).order + 1);

    // set another object with the id^
    // we do this in order to keep the objects in order inside our firestore
    database
        .doc(Provider.of<GlobalNotifier>(context, listen: false)
            .order
            .toString())
        .set({
      // track name
      'track': name,
      // track artist(only spotify)
      'artist': artist,
      // track playback uri(or video id for youtube)
      'playback_uri': playbackUri,
      // track icon
      'icon': icon,
      // the platform from which the track was added
      'platform': platform,
      // the order maintained to be able to order the items in the list
      'order': Provider.of<GlobalNotifier>(context, listen: false).order
    }).then((value) {
      if (kDebugMode) {
        print('Added song');
      }
    }).catchError((error) {
      if (kDebugMode) {
        print("Failed to add data: $error");
      }
    });
  }

  // method for updating the search result every time the user types a new input
  void isEntered() async {
    // do nothing if there is no input
    if (input.isEmpty) {
      if (kDebugMode) {
        print('No input');
      }
      setState(() {
        requiredSongList.clear();
      });
      // clear the list so we don't show previous results
      Provider.of<GlobalNotifier>(context, listen: false)
          .clearRequiredSongList();
      return;
    }

    // search request for spotify
    if (Provider.of<GlobalNotifier>(context, listen: false)
            .platform
            .toLowerCase() ==
        'spotify') {
      // check for connection
      if (!Provider.of<GlobalNotifier>(context, listen: false)
          .connectedSpotify) {
        if (kDebugMode) {
          print('Not connectedSpotify to spotify');
        }
        // inform the user that he's not connected to spotify
        return showDialog(
          context: context,
          builder: (BuildContext context) => const AlertDialog(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Config.colorStyle),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            backgroundColor: Config.back2,
            title: Text(
              'You are not logged in to Spotify!',
              style: TextStyle(color: Config.colorStyle),
            ),
          ),
        );
      }

      final res = await SpotifyController.search(input);

      final json = jsonDecode(res);

      // populate requiredSongList with top songs from Spotify
      for (int i = 0; i < json['tracks']['items'].length; i++) {
        requiredSongList.add(
          {
            'track': json['tracks']['items'][i]['name'],
            'artist': json['tracks']['items'][i]['artists'][0]['name'],
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

    // search request for youtube
    if (Provider.of<GlobalNotifier>(context, listen: false)
            .platform
            .toLowerCase() ==
        'youtube') {
      // check for connection
      if (!Provider.of<GlobalNotifier>(context, listen: false)
          .connectedYouTube) {
        if (kDebugMode) {
          print('Not connectedSpotify to youtube');
        }
        // inform the user that he's not connected to youtube
        return showDialog(
          context: context,
          builder: (BuildContext context) => const AlertDialog(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Config.colorStyle),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            backgroundColor: Config.back2,
            title: Text(
              'You are not logged in to YouTube!',
              style: TextStyle(color: Config.colorStyle),
            ),
          ),
        );
      }

      final res = await YoutubeController.searchFor(input);

      // populate requiredSongList with top songs from YouTube
      for (int i = 0; i < res.length; i++) {
        requiredSongList.add(
          {
            'track': res[i].snippet.title,
            'artist': '',
            'playback_uri': res[i].id.videoId,
            'icon': await YoutubeController.getIcon(
                res[i].id.videoId), // video thumbnail
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
}
