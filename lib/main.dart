// ignore_for_file: deprecated_member_use, prefer_typing_uninitialized_variables, avoid_print
// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:music_pool_app/ui/body/bottom_app_bar.dart';
import 'package:music_pool_app/ui/body/song_list.dart';
import 'package:music_pool_app/ui/secondPage/player/player.dart';
import 'ui/drawer/drawer.dart';
import 'ui/body/platform_buttons.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionNotifier>(
          create: (context) => SessionNotifier(),
          // child: const MyApp(),
        ),
        ChangeNotifierProvider<GlobalNotifier>(
          create: (context) => GlobalNotifier(),
          // child: const MyApp(),
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
  static var sesh = '';
  var timer;

  @override
  void initState() {
    super.initState();
    // simple way of refreshing the token
    // by creating a new one
    // probably not good
    timer = Timer.periodic(const Duration(seconds: 3600), (Timer t) {
      try {
        if (LiveSpotifyController.connected) {
          LiveSpotifyController.auth();
        }
      } on Exception catch (e) {
        print(e);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerAdder(),
      appBar: AppBar(
        toolbarHeight: 160,
        title: Provider.of<SessionNotifier>(context).session.isEmpty
            ? const Text('MusicPool')
            : Text('Session: ' + Provider.of<SessionNotifier>(context).session),
      ),
      bottomNavigationBar: const SongBottomAppBar(),
      body: ListView(
        children: const [
          MusicAddButtons(),
          SongList(),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:html';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:logger/logger.dart';
// import 'package:spotify_sdk/models/connection_status.dart';
// import 'package:spotify_sdk/models/crossfade_state.dart';
// import 'package:spotify_sdk/models/image_uri.dart';
// import 'package:spotify_sdk/models/player_context.dart';
// import 'package:spotify_sdk/models/player_state.dart';
// import 'package:spotify_sdk/spotify_sdk.dart';

// import '.config_for_app.dart';
// import 'widgets/sized_icon_button.dart';

// Future<void> main() async {
//   runApp(const MyApp());
// }

// /// A [StatefulWidget] which uses:
// /// * [spotify_sdk](https://pub.dev/packages/spotify_sdk)
// /// to connect to Spotify and use controls.
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<MyApp> {
//   final redirectURI = 'https://music-pool-app-50127.web.app/auth.html';
//   bool _loading = false;
//   bool _connected = false;
//   final Logger _logger = Logger(
//     //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
//     printer: PrettyPrinter(
//       methodCount: 2, // number of method calls to be displayed
//       errorMethodCount: 8, // number of method calls if stacktrace is provided
//       lineLength: 120, // width of the output
//       colors: true, // Colorful log messages
//       printEmojis: true, // Print an emoji for each log message
//       printTime: true,
//     ),
//   );

//   CrossfadeState? crossfadeState;
//   late ImageUri? currentTrackImageUri;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: StreamBuilder<ConnectionStatus>(
//         stream: SpotifySdk.subscribeConnectionStatus(),
//         builder: (context, snapshot) {
//           _connected = false;
//           var data = snapshot.data;
//           if (data != null) {
//             _connected = data.connected;
//           }
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('SpotifySdk Example'),
//               actions: [
//                 _connected
//                     ? IconButton(
//                         onPressed: disconnect,
//                         icon: const Icon(Icons.exit_to_app),
//                       )
//                     : Container()
//               ],
//             ),
//             body: _sampleFlowWidget(context),
//             bottomNavigationBar: _connected ? _buildBottomBar(context) : null,
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBottomBar(BuildContext context) {
//     return BottomAppBar(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               SizedIconButton(
//                 width: 50,
//                 icon: Icons.queue_music,
//                 onPressed: queue,
//               ),
//               SizedIconButton(
//                 width: 50,
//                 icon: Icons.playlist_play,
//                 onPressed: play,
//               ),
//               SizedIconButton(
//                 width: 50,
//                 icon: Icons.repeat,
//                 onPressed: toggleRepeat,
//               ),
//               SizedIconButton(
//                 width: 50,
//                 icon: Icons.shuffle,
//                 onPressed: toggleShuffle,
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               SizedIconButton(
//                 width: 50,
//                 onPressed: addToLibrary,
//                 icon: Icons.favorite,
//               ),
//               SizedIconButton(
//                 width: 50,
//                 onPressed: () => checkIfAppIsActive(context),
//                 icon: Icons.info,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sampleFlowWidget(BuildContext context2) {
//     return Stack(
//       children: [
//         ListView(
//           padding: const EdgeInsets.all(8),
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 TextButton(
//                   onPressed: connectToSpotifyRemote,
//                   child: const Icon(Icons.settings_remote),
//                 ),
//                 TextButton(
//                   onPressed: getAccessToken,
//                   child: const Text('get auth token '),
//                 ),
//               ],
//             ),
//             const Divider(),
//             const Text(
//               'Player State',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             _connected
//                 ? _buildPlayerStateWidget()
//                 : const Center(
//                     child: Text('Not connected'),
//                   ),
//             const Divider(),
//             const Text(
//               'Player Context',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             _connected
//                 ? _buildPlayerContextWidget()
//                 : const Center(
//                     child: Text('Not connected'),
//                   ),
//             const Divider(),
//             const Text(
//               'Player Api',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Row(
//               children: <Widget>[
//                 TextButton(
//                   onPressed: seekTo,
//                   child: const Text('seek to 20000ms'),
//                 ),
//                 TextButton(
//                   onPressed: seekToRelative,
//                   child: const Text('seek to relative 20000ms'),
//                 ),
//               ],
//             ),
//             const Divider(),
//             const Text(
//               'Crossfade State',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: getCrossfadeState,
//               child: const Text(
//                 'get crossfade state',
//               ),
//             ),
//             // ignore: prefer_single_quotes
//             Text("Is enabled: ${crossfadeState?.isEnabled}"),
//             // ignore: prefer_single_quotes
//             Text("Duration: ${crossfadeState?.duration}"),
//           ],
//         ),
//         _loading
//             ? Container(
//                 color: Colors.black12,
//                 child: const Center(child: CircularProgressIndicator()))
//             : const SizedBox(),
//       ],
//     );
//   }

//   Widget _buildPlayerStateWidget() {
//     return StreamBuilder<PlayerState>(
//       stream: SpotifySdk.subscribePlayerState(),
//       builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
//         var track = snapshot.data?.track;
//         currentTrackImageUri = track?.imageUri;
//         var playerState = snapshot.data;

//         if (playerState == null || track == null) {
//           return Center(
//             child: Container(),
//           );
//         }

//         return Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: <Widget>[
//                 SizedIconButton(
//                   width: 50,
//                   icon: Icons.skip_previous,
//                   onPressed: skipPrevious,
//                 ),
//                 playerState.isPaused
//                     ? SizedIconButton(
//                         width: 50,
//                         icon: Icons.play_arrow,
//                         onPressed: resume,
//                       )
//                     : SizedIconButton(
//                         width: 50,
//                         icon: Icons.pause,
//                         onPressed: pause,
//                       ),
//                 SizedIconButton(
//                   width: 50,
//                   icon: Icons.skip_next,
//                   onPressed: skipNext,
//                 ),
//               ],
//             ),
//             Text(
//                 '${track.name} by ${track.artist.name} from the album ${track.album.name}'),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Playback speed: ${playerState.playbackSpeed}'),
//                 Text(
//                     'Progress: ${playerState.playbackPosition}ms/${track.duration}ms'),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Paused: ${playerState.isPaused}'),
//                 Text('Shuffling: ${playerState.playbackOptions.isShuffling}'),
//               ],
//             ),
//             Text('RepeatMode: ${playerState.playbackOptions.repeatMode}'),
//             Text('Image URI: ${track.imageUri.raw}'),
//             Text('Is episode? ${track.isEpisode}'),
//             Text('Is podcast? ${track.isPodcast}'),
//             _connected
//                 ? spotifyImageWidget(track.imageUri)
//                 : const Text('Connect to see an image...'),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Divider(),
//                 const Text(
//                   'Set Shuffle and Repeat',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 Row(
//                   children: [
//                     const Text(
//                       'Repeat Mode:',
//                     ),
//                     DropdownButton<RepeatMode>(
//                       value: RepeatMode
//                           .values[playerState.playbackOptions.repeatMode.index],
//                       items: const [
//                         DropdownMenuItem(
//                           value: RepeatMode.off,
//                           child: Text('off'),
//                         ),
//                         DropdownMenuItem(
//                           value: RepeatMode.track,
//                           child: Text('track'),
//                         ),
//                         DropdownMenuItem(
//                           value: RepeatMode.context,
//                           child: Text('context'),
//                         ),
//                       ],
//                       onChanged: (repeatMode) => setRepeatMode(repeatMode!),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text('Set shuffle: '),
//                     Switch.adaptive(
//                       value: playerState.playbackOptions.isShuffling,
//                       onChanged: (bool shuffle) => setShuffle(
//                         shuffle,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildPlayerContextWidget() {
//     return StreamBuilder<PlayerContext>(
//       stream: SpotifySdk.subscribePlayerContext(),
//       initialData: PlayerContext('', '', '', ''),
//       builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
//         var playerContext = snapshot.data;
//         if (playerContext == null) {
//           return const Center(
//             child: Text('Not connected'),
//           );
//         }

//         return Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text('Title: ${playerContext.title}'),
//             Text('Subtitle: ${playerContext.subtitle}'),
//             Text('Type: ${playerContext.type}'),
//             Text('Uri: ${playerContext.uri}'),
//           ],
//         );
//       },
//     );
//   }

//   Widget spotifyImageWidget(ImageUri image) {
//     return FutureBuilder(
//         future: SpotifySdk.getImage(
//           imageUri: image,
//           dimension: ImageDimension.large,
//         ),
//         builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
//           if (snapshot.hasData) {
//             return Image.memory(snapshot.data!);
//           } else if (snapshot.hasError) {
//             setStatus(snapshot.error.toString());
//             return SizedBox(
//               width: ImageDimension.large.value.toDouble(),
//               height: ImageDimension.large.value.toDouble(),
//               child: const Center(child: Text('Error getting image')),
//             );
//           } else {
//             return SizedBox(
//               width: ImageDimension.large.value.toDouble(),
//               height: ImageDimension.large.value.toDouble(),
//               child: const Center(child: Text('Getting image...')),
//             );
//           }
//         });
//   }

//   Future<void> disconnect() async {
//     try {
//       setState(() {
//         _loading = true;
//       });
//       var result = await SpotifySdk.disconnect();
//       setStatus(result ? 'disconnect successful' : 'disconnect failed');
//       setState(() {
//         _loading = false;
//       });
//     } on PlatformException catch (e) {
//       setState(() {
//         _loading = false;
//       });
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setState(() {
//         _loading = false;
//       });
//       setStatus('not implemented');
//     }
//   }

//   Future<void> connectToSpotifyRemote() async {
//     try {
//       setState(() {
//         _loading = true;
//       });
//       var result = await SpotifySdk.connectToSpotifyRemote(
//         clientId: SpotifyConfig.clientID,
//         redirectUrl: redirectURI,
//       );
//       setStatus(result
//           ? 'connect to spotify successful'
//           : 'connect to spotify failed');
//       setState(() {
//         _loading = false;
//       });
//     } on PlatformException catch (e) {
//       setState(() {
//         _loading = false;
//       });
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setState(() {
//         _loading = false;
//       });
//       setStatus('not implemented');
//     }
//   }

//   Future<String> getAccessToken() async {
//     try {
//       var authenticationToken = await SpotifySdk.getAuthenticationToken(
//           clientId: SpotifyConfig.clientID,
//           redirectUrl: redirectURI,
//           scope: 'app-remote-control, '
//               'user-modify-playback-state, '
//               'playlist-read-private, '
//               'playlist-modify-public,user-read-currently-playing');
//       setStatus('Got a token: $authenticationToken');
//       return authenticationToken;
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//       return Future.error('$e.code: $e.message');
//     } on MissingPluginException {
//       setStatus('not implemented');
//       return Future.error('not implemented');
//     }
//   }

//   Future getPlayerState() async {
//     try {
//       return await SpotifySdk.getPlayerState();
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future getCrossfadeState() async {
//     try {
//       var crossfadeStateValue = await SpotifySdk.getCrossFadeState();
//       setState(() {
//         crossfadeState = crossfadeStateValue;
//       });
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> queue() async {
//     try {
//       await SpotifySdk.queue(
//           spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> toggleRepeat() async {
//     try {
//       await SpotifySdk.toggleRepeat();
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> setRepeatMode(RepeatMode repeatMode) async {
//     try {
//       await SpotifySdk.setRepeatMode(
//         repeatMode: repeatMode,
//       );
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> setShuffle(bool shuffle) async {
//     try {
//       await SpotifySdk.setShuffle(
//         shuffle: shuffle,
//       );
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> toggleShuffle() async {
//     try {
//       await SpotifySdk.toggleShuffle();
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> play() async {
//     try {
//       await SpotifySdk.play(spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> pause() async {
//     try {
//       await SpotifySdk.pause();
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> resume() async {
//     try {
//       await SpotifySdk.resume();
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> skipNext() async {
//     try {
//       await SpotifySdk.skipNext();
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> skipPrevious() async {
//     try {
//       await SpotifySdk.skipPrevious();
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> seekTo() async {
//     try {
//       await SpotifySdk.seekTo(positionedMilliseconds: 20000);
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> seekToRelative() async {
//     try {
//       await SpotifySdk.seekToRelativePosition(relativeMilliseconds: 20000);
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> addToLibrary() async {
//     try {
//       await SpotifySdk.addToLibrary(
//           spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   Future<void> checkIfAppIsActive(BuildContext context) async {
//     try {
//       var isActive = await SpotifySdk.isSpotifyAppActive;
//       final snackBar = SnackBar(
//           content: Text(isActive
//               ? 'Spotify app connection is active (currently playing)'
//               : 'Spotify app connection is not active (currently not playing)'));

//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     } on PlatformException catch (e) {
//       setStatus(e.code, message: e.message);
//     } on MissingPluginException {
//       setStatus('not implemented');
//     }
//   }

//   void setStatus(String code, {String? message}) {
//     var text = message ?? '';
//     _logger.i('$code$text');
//   }
// }
