// ignore_for_file: deprecated_member_use
// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:music_pool_app/spotify/spotify_auth.dart';
import 'ui//body/sliver_appbar.dart';
import 'ui/body/sliver_list.dart';
import 'ui/drawer/drawer.dart';
import 'ui/body/platform_buttons.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // const keyApplicationId = B4aConfig.keyApplicationId;
  // const keyClientKey = B4aConfig.keyClientKey;

  // const keyParseServerUrl = 'https://parseapi.back4app.com';

  // await Parse().initialize(keyApplicationId, keyParseServerUrl,
  //     clientKey: keyClientKey, debug: true);

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
  var spot = SpotifyAuth();
  String r = 'super';

  // void doCallCloudCodeHello() async {
  //   //Executes a cloud function with no parameters that returns a Map object
  //   final ParseCloudFunction function = ParseCloudFunction('hello');
  //   final ParseResponse parseResponse = await function.execute();
  //   if (parseResponse.success && parseResponse.result != null) {
  //     print(parseResponse.result);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerAdder(),
      body: CustomScrollView(
        // body using slivers due to looks and convenience
        slivers: <Widget>[
          // app bar
          // show the image of the current song playing as background(future implementation)
          sliverAppBar(),
          SliverToBoxAdapter(
            child: TextButton(
              onPressed: () {
                spot.auth();
              },
              child: Text(r), //const Icon(Icons.abc_sharp),
            ),
          ),
          // 2 buttons designed for Spotify and Soundcloud(future implementation)
          sliverToBoxAdapter(context),
          // list of songs that are in queue
          sliverList(),
        ],
      ),
    );
  }
}
