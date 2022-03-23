import 'package:flutter/material.dart';

class GlobalNotifier extends ChangeNotifier {
  int playing = -1;
  bool connected = false;
  bool playState = false;
  int playlistSize = 0;
  int progress = 0;
  int duration = 0;

  setDuration(duration) {
    this.duration = duration;
    notifyListeners();
  }

  setProgress(progress) {
    this.progress = progress;
    notifyListeners();
  }

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
    playing = -1;
    playState = false;
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
