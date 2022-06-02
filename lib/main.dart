import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:MusicPool/global/global.dart';
import 'package:MusicPool/global/session/session.dart';
import 'package:MusicPool/platform_controller/spotify/spotify_controller.dart';
import 'package:MusicPool/ui/body/bottom_app_bar.dart';
import 'package:MusicPool/ui/body/song_list.dart';
import 'package:MusicPool/ui/config.dart';
import 'ui/drawer/drawer.dart';
import 'ui/body/add_song_button.dart';
import 'package:provider/provider.dart';

// only needed in the case of web app
import 'firebase_options.dart';

// main method for running the flutter application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // OPTIONS NEED TO BE REMOVED FOR ANDROID
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionNotifier>(
          create: (context) => SessionNotifier(),
        ),
        ChangeNotifierProvider<GlobalNotifier>(
          create: (context) => GlobalNotifier(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// class for building the home page
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicPoolApp',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with ChangeNotifier {
  // timer made for refreshing the user spotify login every hour(best made by using the refresh token)
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // simple way of refreshing the token, should use refresh token instead
    timer = Timer.periodic(const Duration(seconds: 3600), (Timer t) {
      try {
        if (SpotifyController.connectedSpotify) {
          SpotifyController.auth();
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });
  }

  @override
  void dispose() {
    SpotifyController.pause();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerAdder(),
      appBar: AppBar(
        backgroundColor: Config.back1,
        toolbarHeight: 80,
        title: Provider.of<SessionNotifier>(context).session.isEmpty
            ? const Text('MusicPool')
            : RichText(
                textScaleFactor: 1.5,
                text: TextSpan(
                  text: 'Session: ',
                  style: const TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: Provider.of<SessionNotifier>(context).session,
                      style: const TextStyle(color: Config.colorStyle),
                    )
                  ],
                ),
              ),
      ),
      bottomNavigationBar: Container(
        color: Config.back2,
        child: const SongBottomAppBar(),
      ),
      body: Container(
        color: Config.back2,
        child: ListView(
          children: const [
            AddSongButton(),
            SongList(),
          ],
        ),
      ),
    );
  }
}
