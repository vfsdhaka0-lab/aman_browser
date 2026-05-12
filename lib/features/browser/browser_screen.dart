import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'tab_provider.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() =>
      _BrowserScreenState();
}

class _BrowserScreenState
    extends State<BrowserScreen>
    with WidgetsBindingObserver {
  final TextEditingController urlController =
      TextEditingController();

  bool appInBackground = false;

  String formatUrl(String input) {
    input = input.trim();

    if (input.startsWith("http://") ||
        input.startsWith("https://")) {
      return input;
    }

    if (input.contains(".") &&
        !input.contains(" ")) {
      return "https://$input";
    }

    return "https://www.google.com/search?q=${Uri.encodeComponent(input)}";
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) async {
    final tabProvider =
        context.read<TabProvider>();

    final controller =
        tabProvider.currentTab.controller;

    if (state ==
        AppLifecycleState.paused) {
      appInBackground = true;

      // Resume videos when minimized
      await controller
          ?.evaluateJavascript(
        source: """
document.querySelectorAll('video').forEach(v => {
  if (!v.paused) {
    v.play();
  }
});
""",
      );
    }

    if (state ==
        AppLifecycleState.resumed) {
      appInBackground = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider =
        context.watch<TabProvider>();

    final currentTab =
        tabProvider.currentTab;

    urlController.value = TextEditingValue(
      text: currentTab.url,
      selection: TextSelection.collapsed(
        offset: currentTab.url.length,
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        if (await currentTab.controller
                ?.canGoBack() ??
            false) {
          currentTab.controller?.goBack();
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: TextField(
            controller: urlController,
            textInputAction:
                TextInputAction.go,
            decoration:
                const InputDecoration(
              hintText:
                  "Search or enter URL",
              border: InputBorder.none,
            ),
            onSubmitted:
                (value) async {
              final url =
                  formatUrl(value);

              currentTab.url = url;

              await currentTab
                  .controller
                  ?.loadUrl(
                urlRequest: URLRequest(
                  url: WebUri(url),
                ),
              );

              tabProvider
                  .updateUrl(url);
            },
          ),
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.add),
              onPressed: () {
                tabProvider.addTab(
                  "https://google.com",
                );
              },
            ),

            Stack(
              alignment:
                  Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.tab,
                  ),
                  onPressed: () =>
                      _showTabs(
                    context,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    child: Text(
                      "${tabProvider.tabs.length}",
                      style:
                          const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        body: Column(
          children: [
            currentTab.progress < 1
                ? LinearProgressIndicator(
                    value: currentTab
                        .progress,
                  )
                : const SizedBox(),

            Expanded(
              child: InAppWebView(
                key: ValueKey(
                  currentTab.id,
                ),

                keepAlive:
                    InAppWebViewKeepAlive(),

                initialSettings:
                    InAppWebViewSettings(
                  javaScriptEnabled:
                      true,

                  mediaPlaybackRequiresUserGesture:
                      false,

                  allowsInlineMediaPlayback:
                      true,

                  useShouldOverrideUrlLoading:
                      true,

                  useHybridComposition:
                      true,

                  // MOBILE layout
                  userAgent:
                      "Mozilla/5.0 (Linux; Android 11; Mobile) AppleWebKit/537.36 Chrome/120 Safari/537.36",
                ),

                initialUrlRequest:
                    URLRequest(
                  url: WebUri(
                    currentTab.url,
                  ),
                ),

                onWebViewCreated:
                    (controller) {
                  currentTab.controller =
                      controller;
                },

                shouldOverrideUrlLoading:
                    (controller,
                        navigationAction) async {
                  return NavigationActionPolicy
                      .ALLOW;
                },

                onLoadStart:
                    (controller, url) {
                  if (url != null) {
                    tabProvider
                        .updateUrl(
                      url.toString(),
                    );
                  }
                },

                onLoadStop:
                    (controller,
                        url) async {
                  if (url == null) {
                    return;
                  }

                  final currentUrl =
                      url.toString();

                  tabProvider.updateUrl(
                    currentUrl,
                  );

                  // YouTube desktop ONLY
                  if (currentUrl.contains(
                      "youtube.com")) {
                    await controller
                        .setSettings(
                      settings:
                          InAppWebViewSettings(
                        userAgent:
                            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
                      ),
                    );
                  } else {
                    // restore mobile UA
                    await controller
                        .setSettings(
                      settings:
                          InAppWebViewSettings(
                        userAgent:
                            "Mozilla/5.0 (Linux; Android 11; Mobile) AppleWebKit/537.36 Chrome/120 Safari/537.36",
                      ),
                    );
                  }

                  // Smart playback logic
                  await controller
                      .evaluateJavascript(
                    source: """
(function() {

function setupVideos() {

document.querySelectorAll('video').forEach(video => {

if (video.dataset.listenerAdded === "true") {
  return;
}

video.dataset.listenerAdded = "true";

video.addEventListener('pause', () => {

  if (!document.hidden) {
    video.dataset.userPaused = "true";
  }

});

video.addEventListener('play', () => {
  video.dataset.userPaused = "false";
});

});

}

setupVideos();

document.addEventListener(
'visibilitychange',
function() {

document.querySelectorAll('video')
.forEach(video => {

if (
document.hidden &&
!video.paused
) {
video.dataset.wasPlaying = "true";
}

if (
!document.hidden &&
video.dataset.wasPlaying === "true" &&
video.dataset.userPaused !== "true"
) {
video.play();
}

});

}
);

})();
""",
                  );
                },

                onProgressChanged:
                    (controller,
                        progress) {
                  tabProvider
                      .updateProgress(
                    progress / 100,
                  );
                },
              ),
            ),
          ],
        ),

        bottomNavigationBar:
            SafeArea(
          child: Container(
            height: 55,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                  onPressed:
                      () async {
                    if (await currentTab
                            .controller
                            ?.canGoBack() ??
                        false) {
                      currentTab
                          .controller
                          ?.goBack();
                    }
                  },
                ),

                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  onPressed: () {
                    currentTab
                        .controller
                        ?.reload();
                  },
                ),

                IconButton(
                  icon: const Icon(
                    Icons
                        .arrow_forward,
                  ),
                  onPressed:
                      () async {
                    if (await currentTab
                            .controller
                            ?.canGoForward() ??
                        false) {
                      currentTab
                          .controller
                          ?.goForward();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTabs(
      BuildContext context) {
    final tabProvider =
        context.read<TabProvider>();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount:
              tabProvider.tabs.length,
          itemBuilder:
              (context, index) {
            final tab =
                tabProvider.tabs[index];

            final isActive =
                index ==
                    tabProvider
                        .currentIndex;

            return ListTile(
              tileColor: isActive
                  ? Colors
                      .grey.shade200
                  : null,

              leading: CircleAvatar(
                child: Text(
                  "${index + 1}",
                ),
              ),

              title: Text(
                tab.url,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
              ),

              trailing: IconButton(
                icon: const Icon(
                  Icons.close,
                ),
                onPressed: () {
                  tabProvider
                      .closeTab(index);

                  Navigator.pop(
                    context,
                  );
                },
              ),

              onTap: () {
                tabProvider
                    .switchTab(index);

                Navigator.pop(
                  context,
                );
              },
            );
          },
        );
      },
    );
  }
}