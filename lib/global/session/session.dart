import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:provider/provider.dart';

import 'package:music_pool_app/ui/config.dart';

class Session extends StatefulWidget {
  const Session({Key? key}) : super(key: key);

  @override
  State<Session> createState() => _SessionWidget();
}

class SessionNotifier extends ChangeNotifier {
  String session = '';

  makeSession() {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));

    session = getRandomString(5);
    notifyListeners();
  }

  setSession(String input) {
    session = input;
    notifyListeners();
  }

  emptySession() {
    // ON EXIT DELETE ALL DOCS, SHOULD BE IN EMPTY SESSION
    FirebaseFirestore.instance
        .collection(session)
        .orderBy('order')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    SpotifyController.pause();
    notifyListeners();
  }

  leaveSession() {
    session = '';
    SpotifyController.pause();
    notifyListeners();
  }
}

class _SessionWidget extends State<Session> {
  String input = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Create session'),
          onTap: () {
            Provider.of<SessionNotifier>(context, listen: false).makeSession();
            Provider.of<GlobalNotifier>(context, listen: false).resetNumber();
          },
        ),
        ListTile(
          title: const Text('Join session'),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  backgroundColor: Config.back2,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Config.colorStyle),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  title: const Text('Connect to a session!'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          autofocus: true,
                          maxLength: 20,
                          onChanged: (text) {
                            input = text;
                          },
                          onEditingComplete: () {
                            Provider.of<SessionNotifier>(context, listen: false)
                                .setSession(input);
                            Provider.of<GlobalNotifier>(context, listen: false)
                                .resetNumber();
                            Navigator.pop(context);
                          },
                          cursorColor: Config.colorStyle,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Config.colorStyle)),
                            border: OutlineInputBorder(),
                            hintText: 'Enter a code',
                          ),
                        ),
                        // maybe implement a list of songs found on the platform !?
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          elevation: 2,
                          backgroundColor: Config.colorStyleOposite),
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          elevation: 2,
                          backgroundColor: Config.colorStyle),
                      onPressed: () {
                        Provider.of<SessionNotifier>(context, listen: false)
                            .setSession(input);
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .resetNumber();
                        SpotifyController.pause();
                        Navigator.pop(context, 'Connect');
                      },
                      child: const Text('Connect'),
                    ),
                  ]),
            );
          },
        ),
        if (Provider.of<SessionNotifier>(context).session.isNotEmpty)
          ListTile(
            title: const Text('Empty session',
                style: TextStyle(color: Config.colorStyleOpositeDim)),
            onTap: () {
              Provider.of<SessionNotifier>(context, listen: false)
                  .emptySession();
              Provider.of<GlobalNotifier>(context, listen: false).resetNumber();
            },
          ),
        if (Provider.of<SessionNotifier>(context).session.isNotEmpty)
          ListTile(
            title: const Text(
              'Leave session',
              style: TextStyle(color: Config.colorStyleOposite),
            ),
            onTap: () {
              Provider.of<SessionNotifier>(context, listen: false)
                  .leaveSession();
              Provider.of<GlobalNotifier>(context, listen: false).resetNumber();
            },
          ),
      ],
    );
  }
}
