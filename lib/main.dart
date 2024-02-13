import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:concept_nhv/model.dart';
import 'package:concept_nhv/sample.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Store.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AppModel()),
      ChangeNotifierProvider(create: (context) => CurrentComicModel()),
    ],
    child: MaterialApp.router(
      // theme: ThemeData(useMaterial3: true),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const FirstScreen(),
          ),
          GoRoute(
            path: '/second',
            builder: (context, state) => const SecondScreen(),
          ),
          GoRoute(
            path: '/third',
            builder: (context, state) => const ThirdScreen(),
          ),
        ],
      ),
    ),
  ));
}

class CurrentComicModel extends ChangeNotifier {
  NHComic? currentComic;
  Map<String, String>? headers;

  Future<void> fetchComic(String id) async {
    final (agent, token) = await Store.getCFCookie();

    headers = {
      HttpHeaders.userAgentHeader: agent,
      HttpHeaders.cookieHeader: "cf_clearance=$token",
    };
    final dio = Dio();
    dio
        .get('https://nhentai.net/api/gallery/$id',
            options: Options(headers: headers))
        .then((response) {
      print(response);
      currentComic = NHComic.fromJson(response.data);
      // _fetchedComics.add(NHList.fromJson(Sample.samplejson));
      // pageLoaded += _fetchedComics.last.perPage ?? 0;
      notifyListeners();
    }).catchError((e) {
      print(e);
    });

    // final nhlist = NHList.fromJson(Sample.samplejson);
  }

  void clearComic() {
    currentComic = null;
    notifyListeners();
  }
}

class AppModel extends ChangeNotifier {
  final List<NHList> _fetchedComics = [];

  // todo 20240211 is exposing $page problematic?
  int pageLoaded = 1;

  fetchIndex({page = 1}) async {
    final (agent, token) = await Store.getCFCookie();
    final dio = Dio();
    dio
        .get(
            'https://nhentai.net/api/galleries/search?query=chinese&page=$page',
            options: Options(headers: {
              HttpHeaders.userAgentHeader: agent,
              HttpHeaders.cookieHeader: "cf_clearance=$token",
            }))
        .then((response) {
      print(
          'https://nhentai.net/api/galleries/search?query=chinese&page=$page');
      print(response);
      // _fetchedComics.add(NHList.fromJson(Sample.samplejson));
      _fetchedComics.add(NHList.fromJson(response.data));
      debugPrint(
          "[aa] new first ${_fetchedComics.last.result!.first.id} - ${_fetchedComics.last.result!.first.title!.japanese}");
      // comicsLoaded += _fetchedComics.last.perPage ?? 0;
      // This call tells the widgets that are listening to this model to rebuild.
      notifyListeners();
    }).catchError((e) {
      print(e);
    });

    // final nhlist = NHList.fromJson(Sample.samplejson);
    pageLoaded = page;
  }

  int get comicsLoaded {
    if (_fetchedComics.isEmpty) return 0;

    return _fetchedComics
        .map((e) => e.perPage ?? 0)
        .reduce((value, element) => value + element);
  }

  List<Result>? get comics {
    if (_fetchedComics.isEmpty) return null;

    return _fetchedComics.map((e) => e.result).reduce((value, element) {
      return [...value!, ...element!];
    });
  }
}

class Store {
  static late final Future<Database> database;

  static init() async {
    // uncomment to refresh token, for debug purpose
    deleteDatabase('database.db');

    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE CF(id INTEGER PRIMARY KEY, userAgent TEXT, token TEXT)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  static Future<void> setCFCookie(String userAgent, String token) async {
    final db = await database;
    await db.insert(
      'CF',
      CFConfig(id: 1, userAgent: userAgent, token: token).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<(String, String)> getCFCookie() async {
    final db = await database;
    final cf = await db.query('CF');
    if (cf.isNotEmpty) {
      return (cf.first['userAgent'] as String, cf.first['token'] as String);
    }

    return ("", "");
  }
}

class FirstScreen extends StatelessWidget {
  static const platform = MethodChannel('samples.flutter.dev/cookies');
  const FirstScreen({super.key});

  Future<void> receiveCFCookies(controller, AppModel appModel) async {
    String cookies;
    String? token;
    try {
      token = await platform.invokeMethod<String>('receiveCFCookies');
      if (token == null) {
        return;
      }

      cookies = 'Cookies: $token';
    } on PlatformException catch (e) {
      cookies = "Failed to get cookie: '${e.message}'.";
    }

    debugPrint(cookies);
    // setState(() {
    //   _cookies = batteryLevel;
    // });
    final useragent = await controller.getUserAgent();
    debugPrint(useragent);

    await Store.setCFCookie(useragent, token ?? '');
    await appModel.fetchIndex();
  }

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // debugPrint('Page finished loading: $url');
            // show cookie
            // controller
            //     .runJavaScriptReturningResult('document.cookie')
            //     .then((value) => debugPrint(value as String));
            await receiveCFCookies(
                controller, Provider.of<AppModel>(context, listen: false));
            if (!context.mounted) return;
            context.go('/second');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://nhentai.net'));

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text(
                  'Passing Cloudflare checking, please wait and click "I am human" checkbox if any...'),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: WebViewWidget(controller: controller),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const App(),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          // setState(() {
          //   currentPageIndex = index;
          // });
        },
        // indicatorColor: Colors.amber,
        // selectedIndex: currentPageIndex,
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
    );
  }
}

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
  Widget build(BuildContext context) {
    Map<String, String> query = GoRouterState.of(context).uri.queryParameters;
    final id = query['id']!;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(id),
          ),
          Consumer<CurrentComicModel>(
            builder: (context, currentComicModel, child) {
              if (currentComicModel.currentComic != null) {
                final NHComic c = currentComicModel.currentComic!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final page = index + 1;
                      final mid = c.mediaId;
                      final extMap = {'j': 'jpg', 'p': 'png'};
                      final ext = extMap[c.images!.pages![index].t];
                      final width = c.images!.pages![index].w!;
                      final height = c.images!.pages![index].h!;
                      final url =
                          "https://i.nhentai.net/galleries/$mid/$page.$ext";
                      debugPrint(url);
                      // todo 20240210 1.) builder run this code randomly? maybe try non-builder 2.) get useragent and token somewhere
                      // Stack of comic image, page number
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CachedNetworkImage(
                            imageUrl: url,
                            httpHeaders: currentComicModel.headers,
                            placeholder: (context, url) => AspectRatio(
                              aspectRatio: width / height,
                              child: Container(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => AspectRatio(
                              aspectRatio: width / height,
                              child: Container(
                                child: Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: Text("P$page"),
                            // color: Colors.white,
                          ),
                        ],
                      );
                    },
                    childCount: currentComicModel.currentComic!.numPages,
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.lightBlue[100 * (index % 9)],
                      height: 100.0,
                      child: Text('Item $index'),
                    );
                  },
                  childCount: 10,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Get battery level.
  int currentPageIndex = 0;

  // Get battery level.
  String _cookies = 'N A';

  @override
  Widget build(BuildContext context) {
    // use dio to make a get request to https://nhentai.net/api/galleries/search?query=chinese

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

    return CustomScrollView(
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
          Consumer<AppModel>(
            builder: (BuildContext context, AppModel appModel, Widget? child) {
              /* final (agent, token) = await appModel.getCFCookie();

    final dio = Dio();
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    var acookies = [
      // Cookie('cf_clearance',
      //     'Ofcq589niXh49_O7vC3zg.Sg8Ed4a8tgPeWwnlXDhHI-1706636481-1-AaqJA6uocle51IocDzG+KJl/43EWnL+HTg4ZrBlgAs6mR7Ref8Z5MyU4Qi8atxra6penoChcbxNpp6tjhOsheeg=')
      Cookie('cf_clearance', token ?? '')
        ..domain = 'nhentai.net'
        ..path = '/',
    ];
    cookieJar.saveFromResponse(Uri.parse('nhentai.net'), acookies);

    dio
        .get('https://nhentai.net/api/galleries/search?query=chinese',
            options: Options(headers: {HttpHeaders.userAgentHeader: agent}))
        .then((response) {
      print(response);
    }).catchError((e) {
      print(e);
    });
    
    // final nhlist = NHList.fromJson(Sample.samplejson);
    final nhlist = NHList.fromJson(Sample.samplejson);
    final mid = nhlist.result!.first.mediaId;
    final ext = extMap[nhlist.result!.first.images!.thumbnail!.t];
     */
              final extMap = {'j': 'jpg', 'p': 'png'};

              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180.0,
                  mainAxisExtent: 300,
                  
                  // mainAxisSpacing: 10.0,
                  // crossAxisSpacing: 10.0,
                  // childAspectRatio: 4.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final nhresult = appModel.comics![index];
                    if (index + 1 == appModel.comicsLoaded) {
                      debugPrint(
                          'Loading more... page: ${appModel.pageLoaded + 1}');
                      appModel.fetchIndex(page: appModel.pageLoaded + 1);
                    }
                    debugPrint("index: $index");
                    // if (nhlist == null) return Container();
                    final id = nhresult.id!;
                    final mid = nhresult.mediaId;
                    final title = nhresult.title!.english!;
                    final pages = nhresult.numPages;
                    final ext = extMap[nhresult.images!.thumbnail!.t];
                    var thumbnailLink =
                        "https://t.nhentai.net/galleries/$mid/thumb.$ext";
                    print("https://t.nhentai.net/galleries/$mid/thumb.$ext");

                    if (index % 25 == 0) {
                      final title = nhresult.title!.japanese!;
                      debugPrint("[aa] $index%25 = 0, id = $id ($title)");
                      debugPrint("[aa] ${nhresult.id}");
                    }

                    return Column(
                      children: [
                        Card(
                          // clipBehavior is necessary because, without it, the InkWell's animation
                          // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                          // This comes with a small performance cost, and you should not set [clipBehavior]
                          // unless you need it.
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            onTap: () async {
                              // debugPrint('Card tapped.');
                              Provider.of<CurrentComicModel>(context,
                                      listen: false)
                                  .fetchComic(id);
                              await context.push(Uri(
                                  path: '/third',
                                  queryParameters: {'id': id}).toString());
                              Provider.of<CurrentComicModel>(context,
                                      listen: false)
                                  .clearComic();
                            },
                            child: Column(
                              children: [
                                Image.network(thumbnailLink),
                                // Text(thumbnailLink),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_to_photos_outlined),
                              onPressed: () {},
                            ),
                            Text("${pages}p"),
                            IconButton(
                              icon: const Icon(Icons.favorite_outline),
                              onPressed: () {},
                            ),
                          ],
                        )
                      ],
                    );
                  },
                  // childCount: 1,
                  childCount: appModel.comicsLoaded,
                  // childCount: nhlist.result?.length ?? 100,
                ),
              );
            },
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Center(child: Text('te')),
                // Container(
                //   child: WebViewWidget(controller: controller),
                //   height: 300,
                // ),
              ],
            ),
          )
        ][currentPageIndex],
      ],
    );
  }
}
