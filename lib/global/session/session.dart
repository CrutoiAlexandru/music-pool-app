import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MusicPool/global/global.dart';
import 'package:MusicPool/platform_controller/spotify/spotify_controller.dart';
import 'package:provider/provider.dart';

import 'package:MusicPool/ui/config.dart';

// the SessionNotifier class is a ChangeNotifier that handles all global data involving the current session the user is in
// this is done in order to change data live across multiple screens(in app)
class SessionNotifier extends ChangeNotifier {
  // session is a String that remembers the session(specific code)
  // the code is either created randomly or set by the user
  // this allows the user to create sessions with a specific code(or name) and use them as playlists for multiple people
  // all sessions are public and free to join if you know the code(or name)
  String session = '';

  // method for creating a session with a random session code
  // the current length for the code is of 5, it is composed of both numbers and characters
  // the code IS CASE SENSITIVE
  makeSession() {
    // characters used to create the code
    String _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

    // method for randomly generating a character out of the string ^
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));

    // get a random String of length 5, the complexity if big enough and can be changed at any moment
    session = getRandomString(5);
    notifyListeners();
  }

  // method for setting the session code to a specific code
  setSession(String input) {
    session = input;
    notifyListeners();
  }

  // method for emptying the current session the user is in
  // this deletes all objects in the session directly on the database so all data is lost when executed
  emptySession() {
    FirebaseFirestore.instance
        .collection(session)
        .orderBy('order')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    // in case you delete the objects the spotify player can still be playing(it is independent from out application)
    // therefore we need to pause it manually, it doesn't make sense to keep playing if we emptied the session
    SpotifyController.pause();
    notifyListeners();
  }

  // method for exiting the current session the user is in, simply setting the session(code) to an empty string will do the job
  // as data is loaded in the session based on the session(code)
  leaveSession() {
    session = '';
    // when leaving we have to pause the independent player manually as discussed above^
    SpotifyController.pause();
    notifyListeners();
  }
}

// Session class is used to build the session information based widget in the drawer on the left of the screen
class Session extends StatefulWidget {
  const Session({Key? key}) : super(key: key);

  @override
  State<Session> createState() => _SessionWidget();
}

class _SessionWidget extends State<Session> {
  // the input(code) we pass to out SessionNotifier in order the change to a specific session
  String input = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // U.I. for creating a random session
        ListTile(
          title: const Text('Create session'),
          onTap: () {
            Provider.of<SessionNotifier>(context, listen: false).makeSession();
            Provider.of<GlobalNotifier>(context, listen: false).resetNumber();
          },
        ),
        // U.I. for joining a specific session
        ListTile(
          title: const Text('Join session'),
          onTap: () {
            // dialog box for reading the user input(session code)
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
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                          primary: Config.colorStyle,
                          backgroundColor: Config.colorStyleOpposite),
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          primary: Config.colorStyle,
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
                      child: const Text(
                        'Connect',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ]),
            );
          },
        ),
        // if we are in a session currently
        if (Provider.of<SessionNotifier>(context).session.isNotEmpty)
          // U.I.for emptying the session
          ListTile(
            title: const Text('Empty session',
                style: TextStyle(color: Colors.grey)),
            onTap: () {
              Provider.of<SessionNotifier>(context, listen: false)
                  .emptySession();
              Provider.of<GlobalNotifier>(context, listen: false).resetNumber();
            },
          ),
        // if we are in a session currently
        if (Provider.of<SessionNotifier>(context).session.isNotEmpty)
          // U.I. for exiting the session
          ListTile(
            title: const Text(
              'Leave session',
              style: TextStyle(color: Colors.grey),
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
