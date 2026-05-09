class BrowserTab {
  final int id;

  String url;

  double progress;

  BrowserTab({
    required this.id,
    required this.url,
    this.progress = 0,
  });
}