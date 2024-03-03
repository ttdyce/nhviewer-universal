import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:concept_nhv/model/data_model.dart';
import 'package:concept_nhv/model/state_model.dart';
// import 'package:concept_nhv/sample.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Store.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AppModel()),
      ChangeNotifierProvider(create: (context) => ComicListModel()),
      ChangeNotifierProvider(create: (context) => CurrentComicModel()),
    ],
    child: MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const FirstScreen(),
          ),
          // GoRoute(
          //   path: '/index',
          //   builder: (context, state) => const IndexScreen(),
          // ),
          ShellRoute(
            builder: (context, state, child) {
              return Scaffold(
                body: child,
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    final sortByPopularType =
                        context.read<ComicListModel>().sortByPopularType;
                    if (sortByPopularType == null) {
                      context.read<ComicListModel>().sortByPopularType =
                          NHPopularType.month;
                    } else {
                      context.read<ComicListModel>().sortByPopularType = null;
                    }
                    context.read<AppModel>().isLoading = true;
                    // await context.read<ComicListModel>().fetchPage();
                    // context.read<AppModel>().isLoading = false;
                    context.read<ComicListModel>().fetchPage().then(
                        (value) => context.read<AppModel>().isLoading = false);
                  },
                  child: const Icon(Icons.sort),
                ),
                bottomNavigationBar: Consumer<AppModel>(
                  builder: (context, appModel, child) {
                    return NavigationBar(
                      onDestinationSelected: (int index) {
                        context.goNamed('index');
                        // final actions = {
                        //   // 1: () => context.read<ComicListModel>().fetchFavorite(),
                        //   3: () =>
                        //       context.read<ComicListModel>().fetchCollections(),
                        // };
                        // actions[index]?.call();

                        final screens = {
                          0: () {
                            appModel.navigationIndex = index;
                            context.read<AppModel>().isLoading = true;
                            context
                                .read<ComicListModel>()
                                .fetchIndex(clearComic: true)
                                .then((value) =>
                                    context.read<AppModel>().isLoading = false);
                          },
                          1: () {
                            appModel.navigationIndex = index;
                            // context.go('/favorites');
                          },
                          2: () {
                            // context.read<AppModel>().isLoading = true;
                            // context
                            //     .read<ComicListModel>()
                            //     .fetchSearch('CL-orz', clearComic: true)
                            //     .then((value) =>
                            //         context.read<AppModel>().isLoading = false);
                            // handle on showDialog cancel
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Search'),
                                    content: TextField(
                                      autofocus: true,
                                      onSubmitted: (value) {
                                        appModel.navigationIndex = index;

                                        context.read<AppModel>().isLoading =
                                            true;
                                        context
                                            .read<ComicListModel>()
                                            .fetchSearch(value,
                                                clearComic: true)
                                            .then((value) => context
                                                .read<AppModel>()
                                                .isLoading = false);

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  );
                                });
                          },
                          3: () {
                            appModel.navigationIndex = index;
                            context.read<AppModel>().isLoading = true;
                            context
                                .read<ComicListModel>()
                                .fetchCollections()
                                .then((value) =>
                                    context.read<AppModel>().isLoading = false);
                            // context.go('/collections');
                          },
                          4: () {
                            appModel.navigationIndex = index;
                            // context.go('/settings');
                          },
                        };
                        screens[index]?.call();

                        debugPrint('debug clicked $index');
                        HapticFeedback.lightImpact();
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
            },
            routes: [
              GoRoute(
                name: 'index',
                path: '/index',
                builder: (context, state) => const IndexScreen(),
              ),
              GoRoute(
                name: 'collection',
                path: '/collection',
                builder: (context, state) => const CollectionScreen(),
              ),
              // GoRoute(
              //   path: '/favorites',
              //   builder: (context, state) => const FavoriteScreen(),
              // ),
              // GoRoute(
              //   path: '/search',
              //   builder: (context, state) => const IndexScreen(),
              // ),
              // GoRoute(
              //   path: '/collections',
              //   builder: (context, state) => const CollectionListScreen(),
              // ),
              // GoRoute(
              //   path: '/settings',
              //   builder: (context, state) => const IndexScreen(),
              // ),
            ],
          ),
          GoRoute(
            name: 'third',
            path: '/third',
            builder: (context, state) => const ThirdScreen(),
          ),
        ],
      ),
    ),
  ));
}

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, String> query = GoRouterState.of(context).uri.queryParameters;
    final collectionName = query['collectionName']!;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(collectionName),
            ),
          ),
          FutureBuilder(
            future: Store.getCollection(collectionName),
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
        ],
      ),
    );
  }
}

class CollectionListScreen extends StatelessWidget {
  const CollectionListScreen({super.key});

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
        Consumer<ComicListModel>(
          builder: (BuildContext context, ComicListModel comicListModel,
              Widget? child) {
            List<Map<String, Object?>> collectedComics =
                comicListModel.everyCollection;
            if (collectedComics.isEmpty) {
              return SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // const LinearProgressIndicator(),
                  ],
                ),
              );
            }

            for (var comic in collectedComics) {
              // debugPrint(comic.toString());
              debugPrint(comic['name'].toString());
              debugPrint(comic['comicid'].toString());
              debugPrint(comic['dateCreated'].toString());
              debugPrint(comic['mid'].toString());
              debugPrint("---");
            }

            final favorite = collectedComics
                .where((element) => element['name'] == 'Favorite')
                .toList();
            final next = collectedComics
                .where((element) => element['name'] == 'Next')
                .toList();
            final history = collectedComics
                .where((element) => element['name'] == 'History')
                .toList();

            List<CollectionCover> collections =
                [favorite, next, history].map((e) {
              debugPrint("debug1");
              final firstItem = e.firstOrNull;
              if (firstItem == null) {
                debugPrint("debug3 firstItem is null");
              }
              final mid = firstItem!['mid'] as String;
              var images =
                  NHImages.fromJson(jsonDecode(firstItem['images'] as String));
              return CollectionCover(
                mid: mid,
                collectionName: firstItem['name'] as String,
                collectedCount: e.length,
                thumbnailExt: App.extMap[images.thumbnail!.t!]!,
                thumbnailWidth: images.thumbnail!.w!,
                thumbnailHeight: images.thumbnail!.h!,
              );
            }).toList();

            return CollectionSliverGrid(
              collections: collections,
            );
          },
        ),
      ],
    );
  }
}

class NHLanguage {
  static const chinese = 'language:chinese';
  // 20240215 workaround: sometimes lanugage tag 'chinese' returns 404 (error: does not exist)
  static const chineseWorkaround = [
    '-language:english -language:japanese',
    '汉化',
    '中国'
  ];
  static const japanese = 'language:japanese';
  static const english = 'language:english';
  static const all = '-';
  static const all2 = 'language:-';

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
    late final path;

    if (Platform.isIOS) {
      path = join((await getLibraryDirectory()).path, 'database.db');
    } else {
      path = join(await getDatabasesPath(), 'database.db');
    }
    debugPrint(join((await getLibraryDirectory()).path, 'database.db'));
    debugPrint(join(await getDatabasesPath(), 'database.db'));

    _database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      path,
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

  static Future<void> setCFCookies(String userAgent, String token) async {
    final db = await _database;
    await db.insert(
      'CF',
      CFConfig(userAgent: userAgent, token: token).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<(String, String)> getCFCookies() async {
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

  // todo 20240218 use enum for collection name
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

  static Future<List<Map<String, Object?>>> getEveryCollection() async {
    debugPrint("get every collection...");
    final db = await _database;
    final List<Map<String, Object?>> collectedComics = await db.rawQuery(
        "select * from Collection col left join Comic com on col.comicid = com.id order by dateCreated desc");

    return collectedComics;
  }
}

class FirstScreen extends StatelessWidget {
  static const platform = MethodChannel('samples.flutter.dev/cookies');
  const FirstScreen({super.key});

  Future<void> receiveCFCookies(
      controller, Future<void> Function() fetchIndex) async {
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

    await Store.setCFCookies(useragent, token ?? '');
    await fetchIndex();
  }

  Future<bool> testLastCFCookies() async {
    debugPrint("testLastCFCookies...");
    final (agent, token) = await Store.getCFCookies();
    if (agent.isEmpty || token.isEmpty) {
      return false;
    }
    debugPrint("User agent and token ok!");

    final dio = Dio();
    const url = "https://nhentai.net";
    try {
      await dio.get(url,
          options: Options(headers: {
            HttpHeaders.userAgentHeader: agent,
            HttpHeaders.cookieHeader: "cf_clearance=$token",
          }));
    } on DioException catch (e) {
      debugPrint("DioException: status code=${e.response?.statusCode}");
      return false;
    }

    debugPrint("testLastCFCookies ok!");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController();

    return FutureBuilder(
      future: testLastCFCookies(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          // todo 20240304 Show splash screen while testing existing CFCookies
          return const Center(child: CircularProgressIndicator());
        }

        final bool hasCFCookies = snapshot.data;
        if (hasCFCookies) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            context.read<AppModel>().isLoading = true;
            await context.read<ComicListModel>().fetchIndex();
            if (!context.mounted) return;
            context.read<AppModel>().isLoading = false;
            context.go('/index');
          });
          
          // todo 20240304 Show splash screen while testing existing CFCookies
          return const Center(child: CircularProgressIndicator());
        } else {
          controller
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageFinished: (String url) async {
                  context.read<AppModel>().isLoading = true;
                  await receiveCFCookies(
                      controller,
                      Provider.of<ComicListModel>(context, listen: false)
                          .fetchIndex);
                  if (!context.mounted) return;
                  context.read<AppModel>().isLoading = false;
                  context.go('/index');
                },
              ),
            )
            ..loadRequest(Uri.parse('https://nhentai.net'));
        }

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
      },
    );
  }
}

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
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
      // controller: ScrollController()
      //   ..addListener(() {
      //     debugPrint('scrolling');
      //   }),
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        Consumer<AppModel>(
          builder: (BuildContext context, AppModel appModel, Widget? child) {
            return SliverAppBar(
              clipBehavior: Clip.none,
              // shape: const StadiumBorder(),
              // scrolledUnderElevation: 0.0,
              // titleSpacing: 0.0,
              backgroundColor: Colors.transparent,
              floating:
                  true, // We can also uncomment this line and set `pinned` to true to see a pinned search bar.
              snap: true,
              bottom: showLoadingIfNeeded(appModel.isLoading),
              title: SearchAnchor.bar(
                // barPadding: const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 160, vertical: 0)),
                searchController: appModel.searchController,
                onSubmitted: (value) {
                  appModel.searchController.closeView(value);
                  appModel.navigationIndex = 2;

                  context.read<AppModel>().isLoading = true;
                  context
                      .read<ComicListModel>()
                      .fetchSearch(value, clearComic: true)
                      .then((value) =>
                          context.read<AppModel>().isLoading = false);

                  // Navigator.of(context).pop();
                },
                barTrailing: [
                  // todo 20240302 remove splash effect? like gmail thing
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: ClipOval(
                      child: CachedNetworkImage(
                        // get hash in the url: echo -n "someemail@email.com" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | openssl dgst -sha256
                        imageUrl:
                            "https://www.gravatar.com/avatar/b004c065bc529e98545e27af859152bb74007e535f2c149284117cfb520e76d6?d=retro&f=y",
                        placeholder: (context, url) => Icon(
                          Icons.person,
                          color: Colors.grey.shade300,
                        ),
                        height: IconTheme.of(context).size ?? 24,
                      ),
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: const Icon(Icons.more_vert, color: Colors.black),
                  // )
                ],
                // barLeading: IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.search, color: Colors.black),
                // ),
                barHintText: "Search comic",
                barElevation: MaterialStateProperty.all(0),
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List<Widget>.generate(
                    5,
                    (int index) {
                      return ListTile(
                        titleAlignment: ListTileTitleAlignment.center,
                        title: Text('Initial list item $index'),
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        [
          Consumer<ComicListModel>(
            builder: (BuildContext context, ComicListModel comicListModel,
                Widget? child) {
              if (comicListModel.comics == null) {
                return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // const LinearProgressIndicator(),
                    ],
                  ),
                );
              }

              return ComicSliverGrid(
                  comics: comicListModel.comics!
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
                  comicsLoaded: comicListModel.comicsLoaded,
                  pageLoaded: comicListModel.pageLoaded);
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
          // SliverList(
          //   delegate: SliverChildListDelegate(
          //     [
          //       const Center(child: Text('Search')),
          //     ],
          //   ),
          // ),
          Consumer<ComicListModel>(
            builder: (BuildContext context, ComicListModel comicListModel,
                Widget? child) {
              if (comicListModel.comics == null) {
                return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // const LinearProgressIndicator(),
                    ],
                  ),
                );
              }

              return ComicSliverGrid(
                  comics: comicListModel.comics!
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
                  comicsLoaded: comicListModel.comics!.length,
                  pageLoaded: comicListModel.pageLoaded);
            },
          ),
          Consumer<ComicListModel>(
            builder: (BuildContext context, ComicListModel comicListModel,
                Widget? child) {
              List<Map<String, Object?>> collectedComics =
                  comicListModel.everyCollection;
              if (collectedComics.isEmpty) {
                return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // const LinearProgressIndicator(),
                    ],
                  ),
                );
              }

              for (var comic in collectedComics) {
                // debugPrint(comic.toString());
                debugPrint(comic['name'].toString());
                debugPrint(comic['comicid'].toString());
                debugPrint(comic['dateCreated'].toString());
                debugPrint(comic['mid'].toString());
                debugPrint("---");
              }

              final favorite = collectedComics
                  .where((element) => element['name'] == 'Favorite')
                  .toList();
              final next = collectedComics
                  .where((element) => element['name'] == 'Next')
                  .toList();
              final history = collectedComics
                  .where((element) => element['name'] == 'History')
                  .toList();

              List<CollectionCover> collections =
                  [favorite, next, history].map((e) {
                debugPrint("debug1");
                final firstItem = e.firstOrNull;
                if (firstItem == null) {
                  debugPrint("debug3 firstItem is null");
                }
                final mid = firstItem!['mid'] as String;
                var images = NHImages.fromJson(
                    jsonDecode(firstItem['images'] as String));
                return CollectionCover(
                  mid: mid,
                  collectionName: firstItem['name'] as String,
                  collectedCount: e.length,
                  thumbnailExt: App.extMap[images.thumbnail!.t!]!,
                  thumbnailWidth: images.thumbnail!.w!,
                  thumbnailHeight: images.thumbnail!.h!,
                );
              }).toList();

              return CollectionSliverGrid(
                collections: collections,
              );
            },
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Center(child: Text('Settings')),
              ],
            ),
          )
        ][Provider.of<AppModel>(context).navigationIndex],
        // ][0],
      ],
    );
  }

  // todo 20240227 show arc search like 'loading' animation instead, an overlay at the top of screen
  PreferredSizeWidget? showLoadingIfNeeded(bool isLoading) {
    if (isLoading) {
      return const PreferredSize(
        preferredSize: Size(double.infinity, 4.0),
        child: LinearProgressIndicator(),
      );
    }
    return null;
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
          final reachLastItem = index + 1 == comicsLoaded;
          final noMorePage =
              Provider.of<ComicListModel>(context, listen: false).noMorePage;
          final isLoading =
              Provider.of<AppModel>(context, listen: false).isLoading;
          if (!noMorePage &&
              pageLoaded != null &&
              reachLastItem &&
              !isLoading) {
            debugPrint('Loading more... page: ${pageLoaded! + 1}');
            // todo 20240303 learn more about WidgetsBinding.instance.addPostFrameCallback, it seems to be a workaround?
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                Provider.of<AppModel>(context, listen: false).isLoading = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Loading... page: ${pageLoaded! + 1}, language: ${NHLanguage.currentSetting}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
            // todo 20240227 cannot update isLoading (global state) during build(), design how to show user that it is "loading"
            Provider.of<ComicListModel>(context, listen: false)
                .fetchPage(page: pageLoaded! + 1)
                .then(
                  (_) => Provider.of<AppModel>(context, listen: false)
                      .isLoading = false,
                );
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

          return ComicListItem(
              id: id,
              thumbnailLink: thumbnailLink,
              thumbnailWidth: thumbnailWidth,
              thumbnailHeight: thumbnailHeight,
              title: title,
              mid: mid,
              pages: pages,
              comic: comic);
        },
        // childCount: 1,
        childCount: comicsLoaded,
        // childCount: nhlist.result?.length ?? 100,
      ),
    );
  }
}

class ComicListItem extends StatelessWidget {
  const ComicListItem({
    super.key,
    required this.id,
    required this.thumbnailLink,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.title,
    required this.mid,
    required this.pages,
    required this.comic,
  });

  final String id;
  final String thumbnailLink;
  final int thumbnailWidth;
  final int thumbnailHeight;
  final String title;
  final String mid;
  final int pages;
  final ComicCover comic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Card(
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
                context
                    .push(Uri(path: '/third', queryParameters: {'id': id})
                        .toString())
                    .then((_) =>
                        Provider.of<CurrentComicModel>(context, listen: false)
                            .clearComic());
              },
              child: SimpleCachedNetworkImage(
                url: thumbnailLink,
                width: thumbnailWidth,
                height: thumbnailHeight,
              ),
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
  }
}

class CollectionSliverGrid extends StatelessWidget {
  final List<CollectionCover> collections;

  const CollectionSliverGrid({
    super.key,
    required this.collections,
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
          final collection = collections[index];
          debugPrint("index: $index");
          // if (nhlist == null) return Container();
          final collectionName = collection.collectionName;
          final collectedCount = collection.collectedCount;
          final thumbnailWidth = collection.thumbnailWidth;
          final thumbnailHeight = collection.thumbnailHeight;
          final thumbnailLink = collection.thumbnailLink;
          debugPrint(thumbnailLink);

          return Column(
            children: [
              Expanded(
                child: Card(
                  // clipBehavior is necessary because, without it, the InkWell's animation
                  // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                  // This comes with a small performance cost, and you should not set [clipBehavior]
                  // unless you need it.
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () async {
                      // Provider.of<CurrentComicModel>(context, listen: false)
                      //     .fetchComic(id);
                      // await context.push(
                      //     Uri(path: '/third', queryParameters: {'id': id})
                      //         .toString());
                      // Provider.of<CurrentComicModel>(context, listen: false)
                      //     .clearComic();
                      context.push(
                        Uri(path: '/collection', queryParameters: {
                          'collectionName': collectionName
                        }).toString(),
                      );

                      debugPrint('debug clicked $collectionName');
                    },
                    child: SimpleCachedNetworkImage(
                      url: thumbnailLink,
                      width: thumbnailWidth,
                      height: thumbnailHeight,
                    ),
                  ),
                ),
              ),
              Text(
                collectionName,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$collectedCount collected"),
                ],
              )
            ],
          );
        },
        childCount: 3,
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

class CollectionCover {
  final String mid;
  final String collectionName;
  final int collectedCount;

  final String thumbnailExt;
  final int thumbnailWidth;
  final int thumbnailHeight;

  String get thumbnailLink {
    return "https://t.nhentai.net/galleries/$mid/thumb.$thumbnailExt";
  }

  CollectionCover({
    required this.collectionName,
    required this.collectedCount,
    required this.thumbnailExt,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.mid,
  });

  @override
  String toString() {
    return 'CollectionCover{collectionName: $collectionName, collectedCount: $collectedCount}';
  }
}
