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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BrowserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: "Search or enter URL",
          ),
          onSubmitted: (value) {
            String url = value.startsWith("http")
                ? value
                : "https://www.google.com/search?q=$value";

            webViewController?.loadUrl(
              urlRequest: URLRequest(url: Uri.parse(url)),
            );

            provider.setUrl(url);
          },
        ),
      ),
      body: Column(
        children: [
          provider.progress < 1
              ? LinearProgressIndicator(value: provider.progress)
              : const SizedBox(),

          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(provider.url),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                provider.setProgress(progress / 100);
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
            onPressed: () => webViewController?.goBack(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => webViewController?.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => webViewController?.goForward(),
          ),
        ],
      ),
    );
  }
}