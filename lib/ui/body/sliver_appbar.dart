import 'package:flutter/material.dart';

import '../config.dart';

SliverAppBar sliverAppBar() {
  return const SliverAppBar(
    floating: true,
    expandedHeight: 160.0,
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        'MusicPool: #SESSION SHARE CODE',
        style: TextStyle(color: Colors.white),
      ),
      // background: FlutterLogo(), replace with song image etc
    ),
  );
}
