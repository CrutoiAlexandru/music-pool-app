import 'package:flutter/material.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/platform_controller/platform_controller.dart';
import 'package:music_pool_app/ui/config.dart';

class DrawerAdder extends StatelessWidget {
  const DrawerAdder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Config.back2,
      child: Column(
        // Important: Remove any padding from the ListView.
        // padding: EdgeInsets.zero,
        children: [
          ListView(
            shrinkWrap: true,
            children: const [
              SizedBox(
                height: 100,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Config.colorStyle,
                  ),
                  child: Text('Options'),
                ),
              ),
            ],
          ),
          const Session(),
          const Spacer(),
          const PlatformController(),
        ],
      ),
    );
  }
}
