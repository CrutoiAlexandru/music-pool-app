import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:provider/provider.dart';

class BuildPlayerStateWidget extends StatefulWidget {
  const BuildPlayerStateWidget({Key? key}) : super(key: key);

  @override
  State<BuildPlayerStateWidget> createState() => _BuildPlayerStateWidget();
}

class _BuildPlayerStateWidget extends State<BuildPlayerStateWidget> {
  var prog;
  @override
  Widget build(BuildContext context) {
    prog = Provider.of<GlobalNotifier>(context).progress.toString();
    return Text(prog);
  }
}
