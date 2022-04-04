// ignore_for_file: deprecated_member_use, prefer_typing_uninitialized_variables,
// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/platform_controller/spotify/spotify_controller.dart';
import 'package:music_pool_app/ui/body/bottom_app_bar.dart';
import 'package:music_pool_app/ui/body/song_list.dart';
import 'package:music_pool_app/ui/config.dart';
import 'ui/drawer/drawer.dart';
import 'ui/body/platform/platform_buttons.dart';
import 'package:provider/provider.dart';

// leave here in case of errors
import 'firebase_options.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicPoolApp',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
  var timer;

  @override
  void initState() {
    super.initState();
    // simple way of refreshing the token
    // by creating a new one
    // probably not good
    timer = Timer.periodic(const Duration(seconds: 3600), (Timer t) {
      try {
        if (SpotifyController.connectedSpotify) {
          SpotifyController.auth();
        }
      } on Exception catch (e) {
        print(e);
      }
    });
  }

  @override
  void dispose() {
    SpotifyController.pause();
    timer?.cancel();
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
            MusicAddButtons(),
            SongList(),
          ],
        ),
      ),
    );
  }
}
