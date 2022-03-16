// ignore_for_file: deprecated_member_use
// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:music_pool_app/ui/config.dart';
import 'firebase_options.dart';
import 'ui//body/sliver_appbar.dart';
import 'ui/body/sliver_list.dart';
import 'ui/drawer/drawer.dart';
import 'ui/body/platform_buttons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // var spot = SpotifyAuth();
  final database =
      FirebaseFirestore.instance.collection('song_list').snapshots();
  final data = [];
  var list = [];
  List<Widget> finList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerAdder(),
      appBar: sliverAppBar(),
      body: ListView(
        children: [
          const SpotifyController(),
          sliverToBoxAdapter(context),
          StreamBuilder(
            stream: database,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              data.clear();
              list.clear();
              list = snapshot.data!.docs.toList();

              // data list
              for (int i = 0; i < list.length; i++) {
                print(list.length);
                data.add(list[i].data());
              }

              print('###');

              // data.add(list.data());

              //widget list
              for (int i = 0; i < list.length; i++) {
                print(list.length);
                finList.add(Container(
                  color: Config.colorStyle,
                  height: 100.0,
                  margin: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        elevation: 2,
                        backgroundColor: Config.colorStyle),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.ac_unit,
                          size: 50,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data[i]['track'].toString(),
                              textScaleFactor: 2,
                              style: const TextStyle(
                                  color: Color.fromARGB(230, 255, 255, 255)),
                            ),
                            Text(data[i]['artist'].toString(),
                                style: const TextStyle(
                                    color: Color.fromARGB(150, 255, 255, 255))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ));
              }

              return ListView(
                shrinkWrap: true,
                children: finList,
              );
            },
          ),
        ],
      ),
    );
  }
}
