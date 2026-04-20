import 'package:flutter/material.dart';

class BrowserProvider extends ChangeNotifier {
  String url = "https://google.com";
  double progress = 0;

  void setUrl(String newUrl) {
    url = newUrl;
    notifyListeners();
  }

  void setProgress(double value) {
    progress = value;
    notifyListeners();
  }
}