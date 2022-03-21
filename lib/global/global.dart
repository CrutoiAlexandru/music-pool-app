import 'package:flutter/material.dart';

class GlobalNotifier extends ChangeNotifier {
  int playing = -1;
  bool connected = false;

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
}
