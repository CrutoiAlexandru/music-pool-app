import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config.dart';

//Drawer drawerAdder() {
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
          ListTile(
            title: const Text('Create session'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('ETC'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            onTap: () => SystemNavigator.pop(),
            title: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
    );
  }
}
