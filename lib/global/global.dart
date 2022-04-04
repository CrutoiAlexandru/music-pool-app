import 'package:flutter/material.dart';

class GlobalNotifier extends ChangeNotifier {
  // the number in queue of the song playing
  int playing = -1;
  // connection state TO SPOTIFY
  bool connectedSpotify = false;
  // connection state to YOUTUBE
  bool connectedYouTube = false;
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
  // keep order of the added objects
  int order = 0;
  // keep the last platform the user used to add a song from
  String platform = 'Spotify';
  // keep all the songs received by our search
  var requiredSongList = <Map>[];

  setRequiredSongList(requiredSongList) {
    this.requiredSongList = List.from(requiredSongList);
    notifyListeners();
  }

  clearRequiredSongList() {
    requiredSongList.clear();
    notifyListeners();
  }

  setPlatform(platform) {
    this.platform = platform;
    notifyListeners();
  }

  setOrder(order) {
    this.order = order;
  }

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

  setPlaying(int index) {
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

  setSpotifyConnection(bool input) {
    connectedSpotify = input;
    if (connectedSpotify == false) {
      playing = -1;
      playState = false;
    }
    notifyListeners();
  }

  setYouTubeConnection(bool input) {
    connectedYouTube = input;
    // platform specific
    if (connectedYouTube == false) {
      playing = -1;
      playState = false;
    }
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

  // method for converting our progress and duration from seconds to minutes format 00:00
  static secondsToMinutes(seconds) {
    var converted =
        '${Duration(seconds: seconds)}'.split('.')[0].split(':')[1] +
            ':' +
            '${Duration(seconds: seconds)}'.split('.')[0].split(':')[2];

    return converted;
  }
}
