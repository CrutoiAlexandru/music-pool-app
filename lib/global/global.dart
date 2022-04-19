import 'package:flutter/material.dart';

// GlobalNotifier is a ChangeNotifier meant for handling all global data accross our application
// this is more diferent data that is needed live accross multiple screens and widgets
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

  // method for setting the required song list, this is used in order to update data live concerning the audio we are currently searching
  // used in the list shown when we add an audio source
  setRequiredSongList(requiredSongList) {
    this.requiredSongList = List.from(requiredSongList);
    notifyListeners();
  }

  clearRequiredSongList() {
    requiredSongList.clear();
    notifyListeners();
  }

  // method for knowing on which platform we are searching the audio source on
  // chosen by user between 2 platforms momentarily, YouTube and Spotify
  setPlatform(platform) {
    this.platform = platform;
    notifyListeners();
  }

  // method for ordering the data received from our firestore database
  // firestore does not order the data on their end, we need to do it ourself in a custom way we want
  setOrder(order) {
    this.order = order;
  }

  // know when the Spotify song is over in order to play the next one in queue
  // we need this because we do the queueing ourself
  setOver(over) {
    this.over = over;
    notifyListeners();
  }

  // method for setting globaly the duration of an audio source
  setDuration(duration) {
    this.duration = duration;
    notifyListeners();
  }

  // method for setting globaly the progress of an audio source
  setProgress(progress) {
    this.progress = progress;
    notifyListeners();
  }

  // set the current index as playing
  // this lets other widgets know that an item of this index is playing
  setPlaying(int index) {
    playing = index;
    // when the index is bigger than our playlist size it means we are at the end of the queue
    // therefore we go back to the first item in queue
    if (playing >= playlistSize) {
      playing = 0;
    }
    notifyListeners();
  }

  // reset the playing index to -1
  // this is a number that lets our widgets know notghin is playing because we start ordering our queue starting with 0
  resetNumber() {
    playing = -1;
    notifyListeners();
  }

  // method for knowing when the user is connected to spotify
  setSpotifyConnection(bool input) {
    connectedSpotify = input;
    // if not connected then we can't play anything
    if (connectedSpotify == false) {
      playing = -1;
      playState = false;
    }
    notifyListeners();
  }

  // method for knowing if the user is connected to youtube
  setYouTubeConnection(bool input) {
    connectedYouTube = input;
    // if not connected then we can't play anything
    if (connectedYouTube == false) {
      playing = -1;
      playState = false;
    }
    notifyListeners();
  }

  // method for knowing the current playing state of our audio
  // either playing or paused
  setPlayingState(bool state) {
    playState = state;
    notifyListeners();
  }

  // get the length of our playlist size
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
