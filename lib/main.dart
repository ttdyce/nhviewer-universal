import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:concept_nhv/model.dart';
// import 'package:concept_nhv/sample.dart';
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
  NHComic? _currentComic;

  NHComic? get currentComic => _currentComic;

  set currentComic(NHComic? value) {
    _currentComic = value;

    if (_currentComic != null) {
      final id = _currentComic!.id!;
      final mid = _currentComic!.mediaId!;
      final title = _currentComic!.title!.english!;
      final images = jsonEncode(_currentComic!.images!);
      final pages = _currentComic!.numPages!;
      Store.addComic(
        id: id,
        mid: mid,
        title: title,
        images: images,
        pages: pages,
      );
      Store.collectComic(collectionName: 'History', id: id);
    }
  }

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

  int _navigationIndex = 0;

  int get navigationIndex => _navigationIndex;

  set navigationIndex(int value) {
    _navigationIndex = value;
    notifyListeners();
  }

  /// Fetches the index of comics with optional language and popularity filter.
  ///
  /// The method fetches the comics from the specified page and applies the
  /// language and popularity filters if provided. If the request fails more
  /// than once, it gives up on retrying. In the case of a failure, if the
  /// language is Chinese, it switches to an alternative Chinese language setting
  /// and retries the fetch operation.
  ///
  /// [page] is the page number to fetch from the API.
  /// [language] is the language setting for the comics to fetch.
  /// [sortByPopularType] is the popularity filter, defaults to null.
  /// [retryCount] keeps track of the number of retries attempted.
  Future<void> fetchIndex({
    int page = 1,
    String? language,
    String? sortByPopularType = NHPopularType.allTime,
    int retryCount = 0,
  }) async {
    if (retryCount > 1) {
      debugPrint("fetchIndex retried 2 times, giving up");
      return;
    }

    language = language ?? NHLanguage.currentSetting;
    final (agent, token) = await Store.getCFCookie();
    var url =
        "https://nhentai.net/api/galleries/search?query=$language&page=$page";
    if (sortByPopularType != null) {
      url += "&sort=$sortByPopularType";
    }

    final dio = Dio();
    debugPrint('Loading index: $url');
    try {
      final response = await dio.get(url,
          options: Options(headers: {
            HttpHeaders.userAgentHeader: agent,
            HttpHeaders.cookieHeader: "cf_clearance=$token",
          }));
      print(response);
      _fetchedComics.add(NHList.fromJson(response.data));
      // This call tells the widgets that are listening to this model to rebuild.
      notifyListeners();
    } catch (e) {
      print(e);
      debugPrint('Loading index failed ($url), retrying...');
      if (language == NHLanguage.chinese) {
        language = NHLanguage.chinese2;
        NHLanguage.currentSetting = language;
      }
      fetchIndex(
        page: page,
        language: language,
        sortByPopularType: sortByPopularType,
        retryCount: retryCount + 1,
      );
    }

    pageLoaded = page;
  }

  int get comicsLoaded {
    if (_fetchedComics.isEmpty) return 0;

    return _fetchedComics
        .map((e) => e.perPage ?? 0)
        .reduce((value, element) => value + element);
  }

  List<NHComic>? get comics {
    if (_fetchedComics.isEmpty) return null;

    return _fetchedComics.map((e) => e.result).reduce((value, element) {
      return [...value!, ...element!];
    });
  }
}

class NHLanguage {
  static const chinese = 'language:chinese';
  // 20240215 workaround: sometimes lanugage tag 'chinese' returns 404 (error: does not exist)
  static const chinese2 = '中国';
  static const japanese = 'language:japanese';
  static const english = 'language:english';
  static const all = '-';

  static var currentSetting = chinese;
}

class NHPopularType {
  static const allTime = 'popular';
  static const day = 'popular-today';
  static const week = 'popular-week';
  static const month = 'popular-month';
}

class Store {
  static late final Future<Database> _database;

  static init() async {
    // uncomment to refresh token, for debug purpose
    // deleteDatabase('database.db');

    _database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute(
          'CREATE TABLE CF(userAgent TEXT NOT NULL PRIMARY KEY, token TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE Comic(id TEXT NOT NULL Primary Key, mid TEXT NOT NULL, title TEXT NOT NULL, images TEXT NOT NULL, pages INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE Collection(name TEXT NOT NULL, comicid TEXT NOT NULL, dateCreated TEXT NOT NULL, PRIMARY KEY(`name`, `comicid`))',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  static Future<void> setCFCookie(String userAgent, String token) async {
    final db = await _database;
    await db.insert(
      'CF',
      CFConfig(userAgent: userAgent, token: token).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<(String, String)> getCFCookie() async {
    final db = await _database;
    final cf = await db.query('CF');
    if (cf.isNotEmpty) {
      return (cf.first['userAgent'] as String, cf.first['token'] as String);
    }

    return ("", "");
  }

  // Note that old nhviewer does not store thumbnail
  static Future<int> addComic({
    required String id,
    required String mid,
    required String title,
    required int pages,
    required String images,
  }) async {
    final db = await _database;
    return db.insert(
      'Comic',
      {
        'id': id,
        'mid': mid,
        'title': title,
        'images': images,
        'pages': pages,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //todo 20240218 use enum for collection name
  static Future<int> collectComic({
    required String collectionName,
    required String id,
  }) async {
    final db = await _database;
    return db.insert(
      'Collection',
      {
        'name': collectionName,
        'comicid': id,
        'dateCreated': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> getComic() async {
    final db = await _database;
    final comics = await db.query('Comic');
    for (var comic in comics) {
      debugPrint(comic.toString());
    }
  }

  static Future<List<Map<String, Object?>>> getCollection(
      String collectionName) async {
    debugPrint("get collection: $collectionName");
    final db = await _database;
    // final List<Map<String, Object?>> collectedComics = await db
    //     .query('Collection', where: 'name = ?', whereArgs: [collectionName]);
    final List<Map<String, Object?>> collectedComics = await db.rawQuery(
        "select * from Collection col left join Comic com on col.comicid = com.id where col.name = '$collectionName' order by dateCreated desc");

    return collectedComics;
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
    final useragent = await controller.getUserAgent();
    debugPrint(useragent);

    await Store.setCFCookie(useragent, token ?? '');
    await appModel.fetchIndex();
  }

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController();

    // todo 20240215 test stored CF cookie if any

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
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
              const Text(
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
      bottomNavigationBar: Consumer<AppModel>(
        builder: (context, appModel, child) {
          return NavigationBar(
            onDestinationSelected: (int index) {
              appModel.navigationIndex = index;
            },
            // indicatorColor: Colors.amber,
            selectedIndex: appModel.navigationIndex,
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
          );
        },
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

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
                      final ext = App.extMap[c.images!.pages![index].t];
                      final width = c.images!.pages![index].w!;
                      final height = c.images!.pages![index].h!;
                      final url =
                          "https://i.nhentai.net/galleries/$mid/$page.$ext";
                      debugPrint(url);
                      // Stack of comic image, page number
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          SimpleCachedNetworkImage(
                              url: url, width: width, height: height),
                          Text("P$page"),
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
                    return const LinearProgressIndicator();
                  },
                  childCount: 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SimpleCachedNetworkImage extends StatelessWidget {
  const SimpleCachedNetworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: Provider.of<CurrentComicModel>(context).headers,
      placeholder: (context, url) => AspectRatio(
        aspectRatio: width / height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => AspectRatio(
        aspectRatio: width / height,
        child: const Center(
          child: Icon(
            Icons.error,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class App extends StatefulWidget {
  // 20240215 seriously, why upload gif as thumbnail...
  static final extMap = {'j': 'jpg', 'p': 'png', 'g': 'gif'};
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        const SliverAppBar(
          floating: true,
          snap: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('c-nhv'),
          ),
        ),
        [
          Consumer<AppModel>(
            builder: (BuildContext context, AppModel appModel, Widget? child) {
              return ComicSliverGrid(
                  comics: appModel.comics!
                      .map((e) => ComicCover(
                            id: e.id!,
                            mediaId: e.mediaId!,
                            title: e.title!.english!,
                            images: e.images!,
                            pages: e.numPages!,
                            thumbnailExt: App.extMap[e.images!.thumbnail!.t!]!,
                            thumbnailWidth: e.images!.thumbnail!.w!,
                            thumbnailHeight: e.images!.thumbnail!.h!,
                          ))
                      .toList(),
                  comicsLoaded: appModel.comicsLoaded,
                  pageLoaded: appModel.pageLoaded);
            },
          ),
          FutureBuilder(
            future: Store.getCollection('Favorite'),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return SliverList(
                  delegate: SliverChildListDelegate(
                    [],
                  ),
                );
              }

              List<Map<String, Object?>> collectedComics = snapshot.data;
              for (var comic in collectedComics) {
                // debugPrint(comic.toString());
                debugPrint(comic['name'].toString());
                debugPrint(comic['comicid'].toString());
                debugPrint(comic['dateCreated'].toString());
                debugPrint(comic['mid'].toString());
                debugPrint("---");
              }

              List<ComicCover> favoriteComics = collectedComics.map((e) {
                var images =
                    NHImages.fromJson(jsonDecode(e['images'] as String));
                return ComicCover(
                  id: e['comicid'] as String,
                  mediaId: e['mid'] as String,
                  title: e['title'] as String,
                  images: images,
                  pages: e['pages'] as int,
                  thumbnailExt: App.extMap[images.thumbnail!.t!]!,
                  thumbnailWidth: images.thumbnail!.w!,
                  thumbnailHeight: images.thumbnail!.h!,
                );
              }).toList();

              return ComicSliverGrid(
                comics: favoriteComics,
                comicsLoaded: favoriteComics.length,
              );
            },
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Center(child: Text('Search')),
                // Container(
                //   child: WebViewWidget(controller: controller),
                //   height: 300,
                // ),
              ],
            ),
          ),
          // ComicSliverGrid(
          //     comics: appModel.comics,
          //     comicsLoaded: appModel.comicsLoaded,
          //     pageLoaded: appModel.pageLoaded),
        ][Provider.of<AppModel>(context).navigationIndex],
      ],
    );
  }

}

class ComicSliverGrid extends StatelessWidget {
  final List<ComicCover>? comics;
  final int comicsLoaded;
  // local comics does not have page
  final int? pageLoaded;

  const ComicSliverGrid({
    super.key,
    required this.comics,
    required this.comicsLoaded,
    this.pageLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180.0,
        mainAxisExtent: 300,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final comic = comics![index];
          if (pageLoaded != null && index + 1 == comicsLoaded) {
            debugPrint('Loading more... page: ${pageLoaded! + 1}');
            Provider.of<AppModel>(context, listen: false)
                .fetchIndex(page: pageLoaded! + 1);
          }
          debugPrint("index: $index");
          // if (nhlist == null) return Container();
          final id = comic.id;
          final mid = comic.mediaId;
          final title = comic.title;
          final pages = comic.pages;
          // final ext = App.extMap[comic.images.thumbnail!.t];
          final ext = comic.thumbnailExt;
          // final thumbnailWidth = comic.images.thumbnail!.w!;
          // final thumbnailHeight = comic.images.thumbnail!.h!;
          final thumbnailWidth = comic.thumbnailWidth;
          final thumbnailHeight = comic.thumbnailHeight;
          var thumbnailLink = "https://t.nhentai.net/galleries/$mid/thumb.$ext";
          debugPrint("https://t.nhentai.net/galleries/$mid/thumb.$ext");

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
                    Provider.of<CurrentComicModel>(context, listen: false)
                        .fetchComic(id);
                    await context.push(
                        Uri(path: '/third', queryParameters: {'id': id})
                            .toString());
                    Provider.of<CurrentComicModel>(context, listen: false)
                        .clearComic();
                  },
                  child: SimpleCachedNetworkImage(
                    url: thumbnailLink,
                    width: thumbnailWidth,
                    height: thumbnailHeight,
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
                    onPressed: () {
                      Store.addComic(
                        id: id,
                        mid: mid,
                        title: title,
                        pages: pages,
                        images: jsonEncode(comic.images.toJson()),
                      );
                      Store.collectComic(collectionName: 'Next', id: id);
                    },
                  ),
                  Text("${pages}p"),
                  IconButton(
                    icon: const Icon(Icons.favorite_outline),
                    onPressed: () {
                      Store.addComic(
                        id: id,
                        mid: mid,
                        title: title,
                        pages: pages,
                        images: jsonEncode(comic.images.toJson()),
                      );
                      Store.collectComic(collectionName: 'Favorite', id: id);
                    },
                  ),
                ],
              )
            ],
          );
        },
        // childCount: 1,
        childCount: comicsLoaded,
        // childCount: nhlist.result?.length ?? 100,
      ),
    );
  }
}

class ComicCover {
  final String id;
  final String mediaId;
  final String title;
  final NHImages images;
  final int pages;

  final String thumbnailExt;
  final int thumbnailWidth;
  final int thumbnailHeight;

  ComicCover({
    required this.id,
    required this.mediaId,
    required this.title,
    required this.images,
    required this.pages,
    required this.thumbnailExt,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
  });

  @override
  String toString() {
    return 'ComicCover{id: $id, mediaId: $mediaId, title: $title, images: $images, numPages: $pages}';
  }
}
