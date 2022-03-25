import 'package:flutter/material.dart';

class GlobalNotifier extends ChangeNotifier {
  int playing = -1;
  bool connected = false;
  bool playState = false;
  int playlistSize = 0;
  double progress = 0;
  double duration = 0;
  bool over = false;

  setOver(over) {
    this.over = over;
    notifyListeners();
  }

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
    if (playing == playlistSize) {
      playing = 0;
    }

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
    notifyListeners();
  }
}
