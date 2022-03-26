import 'package:flutter/material.dart';

class GlobalNotifier extends ChangeNotifier {
  // the number in queue of the song playing
  int playing = -1;
  // connection state TO SPOTIFY
  bool connected = false;
  // playing state of player
  bool playState = false;
  // total queue size
  int playlistSize = 0;
  // progress of playing song
  double progress = 0;
  // duration of playing song
  double duration = 0;
  // state of over or not of playing song
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
