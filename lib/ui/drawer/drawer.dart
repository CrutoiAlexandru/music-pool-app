import 'package:flutter/material.dart';
import 'package:MusicPool/global/session/session.dart';
import 'package:MusicPool/platform_controller/platform_controller.dart';
import 'package:MusicPool/ui/config.dart';

// class that creates a drawer widget
// the drawer shows:
//    the session options
//    platform logging options(only show log out if we are logged in)
//    exit button(on mobile)
class DrawerAdder extends StatelessWidget {
  const DrawerAdder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Config.back2,
      child: Column(
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
