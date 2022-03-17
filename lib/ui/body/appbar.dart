import 'package:flutter/material.dart';

AppBar PoolAppBar() {
  return AppBar(
    // floating: true,
    // expandedHeight: 160.0,
    toolbarHeight: 160,
    flexibleSpace: const FlexibleSpaceBar(
      title: Text(
        'MusicPool: #SESSION SHARE CODE',
        style: TextStyle(color: Colors.white),
      ),
      // background: FlutterLogo(), replace with song image etc
    ),
  );
}
