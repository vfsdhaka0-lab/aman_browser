import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'browser_provider.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  InAppWebViewController? webViewController;
  final TextEditingController urlController = TextEditingController();

  String formatUrl(String input) {
    if (input.startsWith("http://") || input.startsWith("https://")) {
      return input;
    } else {
      return "https://www.google.com/search?q=${Uri.encodeComponent(input)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BrowserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: "Search or enter URL",
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            String url = formatUrl(value);

            webViewController?.loadUrl(
              urlRequest: URLRequest(
                url: WebUri(url), // ✅ FIXED
              ),
            );

            provider.setUrl(url);
          },
        ),
      ),

      body: Column(
        children: [
          // 🔄 Loading bar
          provider.progress < 1
              ? LinearProgressIndicator(value: provider.progress)
              : const SizedBox(),

          // 🌐 WebView
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(provider.url), // ✅ FIXED
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                urlController.text = url.toString();
              },
              onLoadStop: (controller, url) {
                urlController.text = url.toString();
              },
              onProgressChanged: (controller, progress) {
                provider.setProgress(progress / 100);
              },
            ),
          ),
        ],
      ),

      // 🔘 Bottom Navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await webViewController?.canGoBack() ?? false) {
                  webViewController?.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => webViewController?.reload(),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () async {
                if (await webViewController?.canGoForward() ?? false) {
                  webViewController?.goForward();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}