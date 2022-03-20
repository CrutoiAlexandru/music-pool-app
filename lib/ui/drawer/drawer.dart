import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/spotify/spotify_controller.dart';
import 'package:music_pool_app/ui/config.dart';

class DrawerAdder extends StatelessWidget {
  const DrawerAdder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        // Important: Remove any padding from the ListView.
        // padding: EdgeInsets.zero,
        children: [
          ListView(
            shrinkWrap: true,
            children: const [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Config.colorStyle,
                ),
                child: Text('Options'),
              ),
            ],
          ),
          const Session(),
          const Spacer(),
          const SpotifyController(),
          if (!kIsWeb)
            ListTile(
              onTap: () => SystemNavigator.pop(),
              title: const Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}
