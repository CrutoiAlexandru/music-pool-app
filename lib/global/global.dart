import 'package:flutter/material.dart';

class GlobalNotifier extends ChangeNotifier {
  int playing = 0;

  playingNumber(index) {
    playing = index;
    notifyListeners();
  }

  resetNumber() {
    playing = 0;
    notifyListeners();
  }
}
