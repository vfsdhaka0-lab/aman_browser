import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserTab {
  final int id;
  String url;
  double progress;

  InAppWebViewController? controller;

  BrowserTab({
    required this.id,
    required this.url,
    this.progress = 0,
    this.controller,
  });
}