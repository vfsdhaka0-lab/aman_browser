import 'package:flutter/material.dart';
import 'tab_model.dart';

class TabProvider extends ChangeNotifier {
  final List<BrowserTab> tabs = [
    BrowserTab(id: 0, url: "https://google.com"),
  ];

  int currentIndex = 0;

  BrowserTab get currentTab => tabs[currentIndex];

  void addTab(String url) {
    tabs.add(BrowserTab(id: tabs.length, url: url));
    currentIndex = tabs.length - 1;
    notifyListeners();
  }

  void switchTab(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void closeTab(int index) {
    if (tabs.length == 1) return;

    tabs.removeAt(index);

    if (currentIndex >= tabs.length) {
      currentIndex = tabs.length - 1;
    }

    notifyListeners();
  }

  void updateUrl(String url) {
    currentTab.url = url;
    notifyListeners();
  }

  void updateProgress(double progress) {
    currentTab.progress = progress;
    notifyListeners();
  }
}
