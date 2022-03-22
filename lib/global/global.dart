import 'package:flutter/material.dart';

class GlobalNotifier extends ChangeNotifier {
  int playing = -1;
  bool connected = false;
  bool playState = false;
  int playlistSize = 0;

  playingNumber(int index) {
    playing = index;
    notifyListeners();
  }

  resetNumber() {
    playing = -1;
    notifyListeners();
  }

  setConnection(bool input) {
    connected = input;
    notifyListeners();
  }

  setPlayingState(bool state) {
    playState = state;
    notifyListeners();
  }

  setPlaylistSize(int input) {
    playlistSize = input;
  }
}
