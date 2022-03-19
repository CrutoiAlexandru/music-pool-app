import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../session/session.dart';
import '../../spotify/spotify_controller.dart';
import '../config.dart';

class DrawerAdder extends StatelessWidget {
  const DrawerAdder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Config.colorStyle,
            ),
            child: Text('Options'),
          ),
          const SpotifyController(),
          const Session(),
          ListTile(
            onTap: () => SystemNavigator.pop(),
            title: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
    );
  }
}
