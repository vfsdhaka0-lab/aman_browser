import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../core/youtube/youtube_service.dart';
import '../../core/player/video_player_screen.dart';
import 'tab_provider.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController urlController = TextEditingController();

  String formatUrl(String input) {
    if (input.startsWith("http")) return input;

    if (input.contains(".")) {
      return "https://$input";
    }

    return "https://www.google.com/search?q=$input";
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = context.watch<TabProvider>();
    final tab = tabProvider.currentTab;

    urlController.text = tab.url;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: urlController,
          onSubmitted: (value) async {
            final url = formatUrl(value);
            tab.controller?.loadUrl(
              urlRequest: URLRequest(url: WebUri(url)),
            );
          },
        ),
      ),
      body: Column(
        children: [
          tab.progress < 1
              ? LinearProgressIndicator(value: tab.progress)
              : const SizedBox(),

          Expanded(
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
              ),

              initialUrlRequest:
                  URLRequest(url: WebUri(tab.url)),

              onWebViewCreated: (controller) {
                tab.controller = controller;
              },

              shouldOverrideUrlLoading:
                  (controller, action) async {
                final url = action.request.url.toString();

                // 🔥 YouTube engine trigger
                if (url.contains("youtube.com/watch")) {
                  final yt = YouTubeService();
                  final stream =
                      await yt.getStreamUrl(url);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VideoPlayerScreen(url: stream),
                    ),
                  );

                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },

              onProgressChanged: (controller, progress) {
                tabProvider.updateProgress(progress / 100);
              },

              onLoadStop: (controller, url) {
                if (url != null) {
                  tabProvider.updateUrl(url.toString());
                }
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await tab.controller?.canGoBack() ?? false) {
                tab.controller?.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => tab.controller?.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await tab.controller?.canGoForward() ?? false) {
                tab.controller?.goForward();
              }
            },
          ),
        ],
      ),
    );
  }
}
