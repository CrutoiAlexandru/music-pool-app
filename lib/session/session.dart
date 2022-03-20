import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui/config.dart';

class Session extends StatefulWidget {
  const Session({Key? key}) : super(key: key);

  @override
  State<Session> createState() => _SessionWidget();
}

class SessionNotifier extends ChangeNotifier {
  String session = '';
  int playing = 0;

  playingNumber(index) {
    playing = index;
    notifyListeners();
  }

  makeSession() {
    playing = 0;
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));

    session = getRandomString(5);
    notifyListeners();
    print(session);
  }

  setSession(String input) {
    playing = 0;
    session = input;
    if (session.isNotEmpty) {
      notifyListeners();
    }
  }

  emptySession() {
    playing = 0;
    // ON EXIT DELETE ALL DOCS, SHOULD BE IN EMPTY SESSION
    FirebaseFirestore.instance.collection(session).get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  leaveSession() {
    playing = 0;
    session = '';
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
          onTap: Provider.of<SessionNotifier>(context).makeSession,
        ),
        ListTile(
          title: const Text('Join session'),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
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
                          backgroundColor: Config.colorStyle),
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
                style: TextStyle(color: Color.fromARGB(255, 255, 81, 0))),
            onTap: Provider.of<SessionNotifier>(context, listen: false)
                .emptySession,
          ),
        if (Provider.of<SessionNotifier>(context).session.isNotEmpty)
          ListTile(
            title: const Text(
              'Leave session',
              style: TextStyle(color: Colors.red),
            ),
            onTap: Provider.of<SessionNotifier>(context, listen: false)
                .leaveSession,
          ),
      ],
    );
  }
}
