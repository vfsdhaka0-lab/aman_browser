import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'tab_provider.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController urlController = TextEditingController();

  String formatUrl(String input) {
    input = input.trim();

    // Already complete URL
    if (input.startsWith("http://") ||
        input.startsWith("https://")) {
      return input;
    }

    // Detect domain names
    if (input.contains(".") && !input.contains(" ")) {
      return "https://$input";
    }

    // Otherwise Google search
    return "https://www.google.com/search?q=${Uri.encodeComponent(input)}";
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = context.watch<TabProvider>();
    final currentTab = tabProvider.currentTab;

    urlController.value = TextEditingValue(
      text: currentTab.url,
      selection: TextSelection.collapsed(
        offset: currentTab.url.length,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: TextField(
          controller: urlController,
          textInputAction: TextInputAction.go,
          decoration: const InputDecoration(
            hintText: "Search or enter URL",
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            final url = formatUrl(value);
            tabProvider.updateUrl(url);
          },
        ),
        actions: [
          // ➕ Add Tab
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              tabProvider.addTab("https://google.com");
            },
          ),

          // 📑 Tabs Button
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tab),
                onPressed: () => _showTabs(context),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 8,
                  child: Text(
                    "${tabProvider.tabs.length}",
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔄 Loading Progress
          currentTab.progress < 1
              ? LinearProgressIndicator(
                  value: currentTab.progress,
                )
              : const SizedBox(),

          // 🌐 WebView
          Expanded(
            child: InAppWebView(
              key: ValueKey(currentTab.id),

              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                useShouldOverrideUrlLoading: true,
              ),

              initialUrlRequest: URLRequest(
                url: WebUri(currentTab.url),
              ),

              shouldOverrideUrlLoading:
                  (controller, navigationAction) async {
                return NavigationActionPolicy.ALLOW;
              },

              onLoadStart: (controller, url) {
                if (url != null) {
                  tabProvider.updateUrl(url.toString());
                }
              },

              onLoadStop: (controller, url) async {
                if (url != null) {
                  tabProvider.updateUrl(url.toString());
                }
              },

              onProgressChanged: (controller, progress) {
                tabProvider.updateProgress(progress / 100);
              },
            ),
          ),
        ],
      ),

      // 🔘 Bottom Navigation
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📑 Tabs Bottom Sheet
  void _showTabs(BuildContext context) {
    final tabProvider = context.read<TabProvider>();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: tabProvider.tabs.length,
          itemBuilder: (context, index) {
            final tab = tabProvider.tabs[index];
            final isActive =
                index == tabProvider.currentIndex;

            return ListTile(
              tileColor:
                  isActive ? Colors.grey.shade200 : null,

              leading: CircleAvatar(
                child: Text("${index + 1}"),
              ),

              title: Text(
                tab.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  tabProvider.closeTab(index);
                  Navigator.pop(context);
                },
              ),

              onTap: () {
                tabProvider.switchTab(index);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}