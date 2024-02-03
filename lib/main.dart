import 'dart:convert';
import 'dart:io';

import 'package:concept_nhv/sample.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const StretchableSliverAppBar());
}

class StretchableSliverAppBar extends StatefulWidget {
  const StretchableSliverAppBar({super.key});

  @override
  State<StretchableSliverAppBar> createState() =>
      _StretchableSliverAppBarState();
}

class _StretchableSliverAppBarState extends State<StretchableSliverAppBar> {
  static const platform = MethodChannel('samples.flutter.dev/cookies');
  // Get battery level.
  int currentPageIndex = 0;

  // Get battery level.
  String _cookies = 'N A';

  Future<void> receiveCookies() async {
    String cookies;
    try {
      final result = await platform.invokeMethod<String>('receiveCookies');
      cookies = 'Cookies: $result';
    } on PlatformException catch (e) {
      cookies = "Failed to get cookie: '${e.message}'.";
    }

    debugPrint(cookies);
    // setState(() {
    //   _cookies = batteryLevel;
    // });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final nhlist = NHList.fromJson(Sample.samplejson);
    final extMap = {'j': 'jpg', 'p': 'png'};
    final mid = nhlist.result!.first.mediaId;
    final ext = extMap[nhlist.result!.first.images!.thumbnail!.t];
    // debugPrint("https://t.nhentai.net/galleries/$mid/thumb.$ext");

    // final dio = Dio();

    // dio
    //     .get('https://nhentai.net/api/galleries/search?query=chinese',
    //         options: Options(headers: {HttpHeaders.userAgentHeader: "NHViewer client concept"}))
    //     .then((response) {
    //       print(response);
    //     })
    //     .catchError((e) {
    //       print(e);
    //     });
    final controller = WebViewController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            // debugPrint('Page finished loading: $url');
            // show cookie
            // controller
            //     .runJavaScriptReturningResult('document.cookie')
            //     .then((value) => debugPrint(value as String));
            receiveCookies();
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://nhentai.net'));

    controller.getUserAgent().then((value) {
      debugPrint(value);
    });

    return MaterialApp(
        // theme: ThemeData(useMaterial3: true),
        home: Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('c-nhv'),
            ),
          ),
          [
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisExtent: 240,
                // mainAxisSpacing: 10.0,
                // crossAxisSpacing: 10.0,
                // childAspectRatio: 4.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final mid = nhlist.result![index].mediaId;
                  final ext =
                      extMap[nhlist.result![index].images!.thumbnail!.t];
                  var thumbnailLink = "";
                  print("https://t.nhentai.net/galleries/$mid/thumb.$ext");

                  return Card(
                    // clipBehavior is necessary because, without it, the InkWell's animation
                    // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                    // This comes with a small performance cost, and you should not set [clipBehavior]
                    // unless you need it.
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        debugPrint('Card tapped.');
                      },
                      child: SizedBox(
                        // width: 300,
                        // height: 900,
                        child: Column(
                          children: [
                            Image.network(thumbnailLink),
                            // Text(thumbnailLink),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: 5,
                // childCount: nhlist.result?.length ?? 100,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Center(child: Text('te')),
                  Container(
                    child: WebViewWidget(controller: controller),
                    height: 300,
                  ),
                ],
              ),
            )
          ][currentPageIndex],
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        // indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.folder),
            icon: Icon(Icons.folder_outlined),
            label: 'Collections',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    ));
  }
}
