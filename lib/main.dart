import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:concept_nhv/model/data_model.dart';
import 'package:concept_nhv/model/state_model.dart';
import 'package:concept_nhv/theme.dart';
// import 'package:concept_nhv/sample.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // workaround for 120hz (Android) https://github.com/flutter/flutter/issues/35162
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
  await Store.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AppModel()),
      ChangeNotifierProvider(create: (context) => ComicListModel()),
      ChangeNotifierProvider(create: (context) => CurrentComicModel()),
    ],
    child: MaterialApp.router(
      theme: const NHVMaterialTheme(TextTheme()).dark(),
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
                floatingActionButton: Consumer<AppModel>(
                  builder: (context, appModel, child) {
                    if (appModel.navigationIndex != 0) {
                      return Container();
                    }

                    // only show FAB in index screen
                    return GestureDetector(
                      onLongPress: () {
                        // mostly same with FAB press below, here it change to NHPopularType.allTime
                        final sortByPopularType =
                            context.read<ComicListModel>().sortByPopularType;
                        if (sortByPopularType != NHPopularType.allTime) {
                          context.read<ComicListModel>().sortByPopularType =
                              NHPopularType.allTime;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Sort by popular type: ${NHPopularType.allTime}'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          context.read<ComicListModel>().sortByPopularType =
                              null;
                        }
                        context.read<AppModel>().isLoading = true;
                        // await context.read<ComicListModel>().fetchPage();
                        // context.read<AppModel>().isLoading = false;
                        context.read<ComicListModel>().fetchPage().then(
                            (value) =>
                                context.read<AppModel>().isLoading = false);
                      },
                      child: FloatingActionButton(
                        onPressed: () {
                          // logic is not straight forward here
                          final sortByPopularType =
                              context.read<ComicListModel>().sortByPopularType;
                          if (sortByPopularType != NHPopularType.month) {
                            context.read<ComicListModel>().sortByPopularType =
                                NHPopularType.month;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Sort by popular type: ${NHPopularType.month}'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            context.read<ComicListModel>().sortByPopularType =
                                null;
                          }
                          context.read<AppModel>().isLoading = true;
                          // await context.read<ComicListModel>().fetchPage();
                          // context.read<AppModel>().isLoading = false;
                          context.read<ComicListModel>().fetchPage().then(
                              (value) =>
                                  context.read<AppModel>().isLoading = false);
                        },
                        child: const Icon(Icons.sort),
                      ),
                    );
                  },
                ),
                bottomNavigationBar: Consumer<AppModel>(
                  builder: (context, appModel, child) {
                    return NavigationBar(
                      onDestinationSelected: (int index) {
                        debugPrint('debug clicked $index');
                        // context.goNamed('index');
                        if (appModel.searchController.isOpen) {
                          appModel.searchController.text = '';
                          appModel.searchController.closeView(null);
                        }

                        final screens = {
                          0: () {
                            // todo 20240304 handle keeping loaded comics, go back from search, and scroll to top
                            appModel.navigationIndex = index;
                            context.read<AppModel>().isLoading = true;
                            context
                                .read<ComicListModel>()
                                .fetchIndex(clearComic: true)
                                .then((value) {
                              String? message;
                              if (value == 404) {
                                message = 'API issue (404)';
                              }
                              if (value == 403) {
                                message = 'CF Cookies issue (403)';
                              }
                              if (message != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                              context.read<AppModel>().isLoading = false;
                            });
                          },
                          1: () {
                            appModel.navigationIndex = index;
                            context
                                .read<ComicListModel>()
                                .fetchEveryCollectionFuture();
                          },
                          2: () {
                            appModel.navigationIndex = index;
                            context
                                .read<ComicListModel>()
                                .fetchEveryCollectionFuture();
                          },
                        };
                        screens[index]?.call();
                        context.goNamed('index');

                        HapticFeedback.lightImpact();
                      },
                      // indicatorColor: Colors.amber,
                      selectedIndex: appModel.navigationIndex,
                      destinations: const <Widget>[
                        NavigationDestination(
                          selectedIcon: Icon(Icons.home),
                          icon: Icon(Icons.home_outlined),
                          label: 'Index',
                        ),
                        NavigationDestination(
                          selectedIcon: Icon(Icons.favorite),
                          icon: Icon(Icons.favorite_border),
                          label: 'Favorites',
                        ),
                        NavigationDestination(
                          selectedIcon: Icon(Icons.folder),
                          icon: Icon(Icons.folder_outlined),
                          label: 'Collections',
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
            ],
          ),
          GoRoute(
            name: 'third',
            path: '/third',
            builder: (context, state) {
              final id = state.uri.queryParameters['id'] ?? '';
              Store.getOption("lastSeenOffset-$id").then((lastSeenOffset) {
                debugPrint(
                    "getOption lastSeenOffset-$id ${lastSeenOffset.toString()}");
                if (lastSeenOffset.isNotEmpty) {
                  context.read<CurrentComicModel>().scrollController.animateTo(
                        double.parse(lastSeenOffset),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                      );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Loaded last seen page"),
                    action: SnackBarAction(
                      label: "Back to top",
                      onPressed: () => context
                          .read<CurrentComicModel>()
                          .scrollController
                          ?.jumpTo(0),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              });

              return ThirdScreen();
            },
          ),
          GoRoute(
            name: 'settings',
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
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
            title: Text(collectionName),
          ),
          CollectionSliver(
            collectionName: collectionName,
          ),
        ],
      ),
    );
  }
}

class CollectionSliver extends StatelessWidget {
  final String collectionName;

  const CollectionSliver({super.key, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return Consumer<ComicListModel>(
      builder: (context, comicListModel, child) => FutureBuilder(
        future: comicListModel.everyCollectionFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const SliverFillRemaining(
              hasScrollBody: false,
            );
          }

          List<Map<String, Object?>> everyCollectedComics = snapshot.data;
          List<Map<String, Object?>> collectedComics = everyCollectedComics
              .where((element) => element['name'] == collectionName)
              .toList();

          if (collectedComics.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text("No comics in $collectionName"),
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

          List<ComicCover> collectionComics = collectedComics.map((e) {
            try {
              var images = NHImages.fromJson(jsonDecode(e['images'] as String));
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
            } on FormatException catch (e) {
              debugPrint('images is not json (old format images)');
            }

            var images = e['images'] as String;
            return ComicCover(
              id: e['comicid'] as String,
              mediaId: e['mid'] as String,
              title: e['title'] as String,
              images: NHImages(pages: null, cover: null, thumbnail: null),
              pages: e['pages'] as int,
              thumbnailExt: App.extMap[images[0]] ?? 'jpg',
              thumbnailWidth: 9,
              thumbnailHeight: 16,
            );
          }).toList();

          return ComicSliverGrid(
            comics: collectionComics,
            comicsLoaded: collectionComics.length,
            collectionName: collectionName,
          );
        },
      ),
    );
  }
}

class CollectionListScreen extends StatelessWidget {
  const CollectionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ComicListModel>(
      builder: (context, comicListModel, child) => FutureBuilder(
          future: comicListModel.everyCollectionFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SliverFillRemaining(
                hasScrollBody: false,
              );
            }

            List<Map<String, Object?>> collectedComics = snapshot.requireData;

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

            List<CollectionCover> collections = {
              'History': history,
              'Next': next,
              'Favorite': favorite,
            }.entries.map((e) {
              final firstItem = e.value.firstOrNull;
              if (firstItem == null) {
                return CollectionCover.emptyCollection(
                  collectionName: e.key,
                );
              }
              final mid = firstItem['mid'] as String;
              try {
                var images = NHImages.fromJson(
                    jsonDecode(firstItem['images'] as String));
                return CollectionCover(
                  mid: mid,
                  collectionName: firstItem['name'] as String,
                  collectedCount: e.value.length,
                  thumbnailExt: App.extMap[images.thumbnail!.t!]!,
                  thumbnailWidth: images.thumbnail!.w!,
                  thumbnailHeight: images.thumbnail!.h!,
                );
              } on FormatException catch (e) {
                debugPrint('images is not json (old format images)');
              }

              var images = firstItem['images'] as String;
              return CollectionCover(
                mid: mid,
                collectionName: firstItem['name'] as String,
                collectedCount: e.value.length,
                thumbnailExt: App.extMap[images[0]]!,
                thumbnailWidth: 9,
                thumbnailHeight: 16,
              );
            }).toList();

            return CollectionSliverGrid(
              collections: collections,
            );
          }),
    );
  }
}

enum NHLanguage {
  all,
  chinese,
  japanese,
  english;

  String get queryString {
    switch (this) {
      case NHLanguage.all:
        return '-';
      case NHLanguage.chinese:
        return 'language:chinese';
      case NHLanguage.japanese:
        return 'language:japanese';
      case NHLanguage.english:
        return 'language:english';
    }
  }

  List<String> get alternatives {
    switch (this) {
      case NHLanguage.all:
        return ['language:-'];
      case NHLanguage.chinese:
        return ['-language:english -language:japanese', '汉化', '中国'];
      case NHLanguage.japanese:
      case NHLanguage.english:
      default:
        return [];
    }
  }

  // todo 20240330 change default to read from settings and persist to settings
  static NHLanguage current = NHLanguage.chinese;
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
    late final String path;

    if (Platform.isIOS) {
      path = join((await getLibraryDirectory()).path, 'database.db');
    } else {
      path = join(await getDatabasesPath(), 'database.db');
    }
    // debugPrint(join((await getLibraryDirectory()).path, 'database.db'));
    // debugPrint(join(await getDatabasesPath(), 'database.db'));

    // uncomment to refresh token, for debug purpose
    // deleteDatabase(path);
    _database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      path,
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute(
          'CREATE TABLE Options(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, value TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE Comic(id TEXT NOT NULL Primary Key, mid TEXT NOT NULL, title TEXT NOT NULL, images TEXT NOT NULL, pages INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE Collection(name TEXT NOT NULL, comicid TEXT NOT NULL, dateCreated TEXT NOT NULL, PRIMARY KEY(`name`, `comicid`))',
        );
        await db.execute(
          'CREATE TABLE SearchHistory(id INTEGER PRIMARY KEY, query TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      // todo 20240306 combine every db migration into version 1, as release version 1
      version: 4,
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute(
            'CREATE TABLE Options(id INTEGER PRIMARY KEY, name TEXT NOT NULL, value TEXT NOT NULL)',
          );
        }
        if (oldVersion < 3) {
          db.execute(
            'DROP TABLE Options',
          );
          db.execute(
            'CREATE TABLE Options(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, value TEXT NOT NULL)',
          );
        }
        if (oldVersion < 4) {
          db.execute(
            'CREATE TABLE SearchHistory(id INTEGER PRIMARY KEY, query TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)',
          );
        }
      },
    );

    // todo 20240308 load comic language from Options
  }

  static Future<void> setCFCookies(String userAgent, String token) async {
    final db = await _database;
    await db.insert(
      'Options',
      {
        'name': 'userAgent',
        'value': userAgent,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'Options',
      {
        'name': 'token',
        'value': token,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<(String, String)> getCFCookies() async {
    final db = await _database;
    final userAgent = await db
        .rawQuery('select value from Options where name = ?', ['userAgent']);
    final token = await db
        .rawQuery('select value from Options where name = ?', ['token']);
    if (userAgent.isNotEmpty && token.isNotEmpty) {
      return (
        userAgent.first['value'] as String,
        token.first['value'] as String
      );
    }

    return ("", "");
  }

  static Future<int> deleteCFCookies() async {
    final db = await _database;
    final rowsDeleted = await db.delete(
      'Options',
      where: 'name = ? OR name = ?',
      whereArgs: ['userAgent', 'token'],
    );

    return rowsDeleted;
  }

  static Future<void> setOption(String name, String value) async {
    final db = await _database;
    await db.insert(
      'Options',
      {
        'name': name,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String> getOption(String name) async {
    final db = await _database;
    final option = await db.query(
      'Options',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (option.isNotEmpty) {
      return option.first['value'] as String;
    }

    return "";
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
    String? dateCreated,
  }) async {
    final db = await _database;
    return db.insert(
      'Collection',
      {
        'name': collectionName,
        'comicid': id,
        'dateCreated': dateCreated ?? DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> uncollectComic({
    required String collectionName,
    required String id,
  }) async {
    final db = await _database;
    return db.delete(
      'Collection',
      where: 'name = ? AND comicid = ?',
      whereArgs: [collectionName, id],
    );
    //   return db.insert(
    //     'Collection',
    //     {
    //       'name': collectionName,
    //       'comicid': id,
    //       'dateCreated': DateTime.now().toIso8601String(),
    //     },
    //     conflictAlgorithm: ConflictAlgorithm.replace,
    //   );
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
    final List<Map<String, Object?>> collectedComics = await db.rawQuery(
        "select * from Collection col left join Comic com on col.comicid = com.id where col.name = '$collectionName' order by dateCreated desc");

    return collectedComics;
  }

  static Future<List<Map<String, Object?>>> getEveryCollection() async {
    debugPrint("get every collection...");
    final db = await _database;
    // final List<Map<String, Object?>> collectedComics = await db.rawQuery(
    //     "select * from Collection col left join Comic com on col.comicid = com.id order by dateCreated desc");
    final List<Map<String, Object?>> collectedComics = await db.rawQuery(
        "select * from Collection col, Comic com where col.comicid = com.id order by dateCreated desc");

    debugPrint('testing comics...');
    final List<Map<String, Object?>> comics =
        await db.rawQuery("select * from Comic");

    return collectedComics;
  }

  static Future<void> addSearchHistory(String q) async {
    final db = await _database;
    await db.insert(
      'SearchHistory',
      {
        'query': q,
      },
      // conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<Map<String, Object?>>> getSearchHistory() async {
    final db = await _database;
    final queryHistory =
        await db.query('SearchHistory', orderBy: 'created_at DESC');
    return queryHistory;
  }

  static Future<void> deleteSearchHistory(String e) async {
    final db = await _database;
    await db.delete(
      'SearchHistory',
      where: 'query = ?',
      whereArgs: [e],
    );
  }
}

class FirstScreen extends StatelessWidget {
  static const platform = MethodChannel('samples.flutter.dev/cookies');
  const FirstScreen({super.key});

  Future<(String, String)> receiveCFCookies(
      controller, Future<void> Function() fetchIndex) async {
    String cookies;
    String? token;
    try {
      token = await platform.invokeMethod<String>('receiveCFCookies');
      if (token == null) {
        return ("", "");
      }
      debugPrint("receiveCFCookies1: ---$token===");
      if (token.contains("cf_clearance=")) {
        token = token
            .split("; ")
            .firstWhere((element) => element.startsWith("cf_clearance="))
            .split("=")[1];
      }

      cookies = 'Cookies: $token';
    } on PlatformException catch (e) {
      cookies = "Failed to get cookie: '${e.message}'.";
    }

    debugPrint(cookies);
    final String useragent = await controller.getUserAgent();
    debugPrint(useragent);

    await Store.setCFCookies(useragent, token ?? '');
    await fetchIndex();
    return (useragent, token ?? '');
  }

  Future<bool> testLastCFCookies() async {
    debugPrint("testLastCFCookies...");
    final (agent, token) = await Store.getCFCookies();
    if (agent.isEmpty || token.isEmpty) {
      debugPrint("Note: Found empty user agent or token, still testing...");
      // return false;
    } else {
      debugPrint("Found previous user agent and token! testing...");
    }

    final dio = Dio();
    const url = "https://nhentai.net";
    try {
      await dio.get(url,
          options: Options(headers: {
            HttpHeaders.userAgentHeader: agent,
            HttpHeaders.cookieHeader: "cf_clearance=$token",
          }));
    } on DioException catch (e) {
      debugPrint(
          "testing failed. DioException: status code=${e.response?.statusCode}");
      await Store.deleteCFCookies();
      return false;
    }

    debugPrint("testLastCFCookies ok!");
    debugPrint("testLastCFCookies $token");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController();

    return Scaffold(
      body: FutureBuilder(
        future: testLastCFCookies(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            // todo 20240304 Show splash screen while testing existing CFCookies
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Text(
                  'Loading...',
                ),
              ],
            ));
          }

          final bool passTest = snapshot.data;
          if (passTest) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              context.read<AppModel>().isLoading = true;
              await context.read<ComicListModel>().fetchIndex();
              if (!context.mounted) return;
              context.read<AppModel>().isLoading = false;
              context.go('/index');
            });

            // todo 20240304 Show splash screen while testing existing CFCookies
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Loading index...'),
                ],
              ),
            );
          } else {
            controller
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onPageFinished: (String url) async {
                    context.read<AppModel>().isLoading = true;
                    // handle "Click to verify you are human" before go /index, checking if Cookie is set on page loaded
                    final (_, token) = await receiveCFCookies(
                        controller,
                        Provider.of<ComicListModel>(context, listen: false)
                            .fetchIndex);
                    //retest new cookie
                    if (!await testLastCFCookies()) {
                      return;
                    }
                    if (!context.mounted || token.isEmpty) return;
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
      ),
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
  ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, String> query = GoRouterState.of(context).uri.queryParameters;
    final id = query['id']!;

    return Scaffold(
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (context.read<CurrentComicModel>().scrollController.offset !=
                0) {
              Store.setOption(
                  "lastSeenOffset-$id",
                  context
                      .read<CurrentComicModel>()
                      .scrollController
                      .offset
                      .toString());
              debugPrint(
                  "setOption lastSeenOffset-$id ${context.read<CurrentComicModel>().scrollController.offset.toString()}");
            }
          }
          return false; // Return true if the notification should be canceled.
        },
        child: CustomScrollView(
          controller: context.read<CurrentComicModel>().scrollController,
          slivers: <Widget>[
            SliverAppBar(
              title: Text(id),
              // todo 20240322 allow add to collection when viewing comic, required mid+title+pages+comic.images
              // actions: [
              //   IconButton(
              //     icon: const Icon(Icons.favorite_outline),
              //     onPressed: () {
              //       Store.addComic(
              //         id: id,
              //         mid: mid,
              //         title: title,
              //         pages: pages,
              //         images: jsonEncode(comic.images.toJson()),
              //       );
              //       Store.collectComic(collectionName: 'Favorite', id: id);
              //     },
              //   ),
              // ],
            ),
            Consumer<CurrentComicModel>(
              builder: (context, currentComicModel, child) {
                if (currentComicModel.currentComic == null) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return const LinearProgressIndicator();
                      },
                      childCount: 1,
                    ),
                  );
                }

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
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            title: Text('Settings'),
          ),
          SliverList.list(children: [
            ListTile(
              title: const Text('Language'),
              subtitle: Text(NHLanguage.current.queryString),
              onTap: () {
                showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      // todo 20240308 persist changes of NHLanguage.current
                      return SimpleDialog(
                        title: const Text('Language'),
                        children: [
                          SimpleDialogOption(
                            child: Text('All'),
                            onPressed: () {
                              NHLanguage.current = NHLanguage.all;
                              Navigator.of(context).pop(true);
                            },
                          ),
                          SimpleDialogOption(
                            child: Text('Chinese'),
                            onPressed: () {
                              NHLanguage.current = NHLanguage.chinese;
                              Navigator.of(context).pop(true);
                            },
                          ),
                          SimpleDialogOption(
                            child: Text('English'),
                            onPressed: () {
                              NHLanguage.current = NHLanguage.english;
                              Navigator.of(context).pop(true);
                            },
                          ),
                          SimpleDialogOption(
                            child: Text('Japanese'),
                            onPressed: () {
                              NHLanguage.current = NHLanguage.japanese;
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    }).then((value) {
                  if (value == null || value == false) {
                    return;
                  }
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language set to `${NHLanguage.current}`'),
                    ),
                  );
                });
              },
            ),
            ListTile(
              title: const Text('Diagnose'),
              onTap: () {
                // todo 20240308 Check api status of all language query, and the real search with queries. Show result in real time.
              },
            ),
            const Divider(),
            const ListTile(title: Text('About')),
            ListTile(
              title: const Text('Load json (network)'),
              onTap: () async {
                // open dialog to set url
                var url = await showDialog<String?>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Enter URL'),
                      content: TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'URL',
                        ),
                        onSubmitted: (value) {
                          Navigator.of(context).pop(value);
                        },
                      ),
                    );
                  },
                );

                if (url == null || url.isEmpty) {
                  return;
                }

                final comicResponse =
                    await Dio().get<String>("$url/comics.json");
                final collectionResponse =
                    await Dio().get<String>("$url/collections.json");
                final comicJson = List<Map<String, dynamic>>.from(
                    jsonDecode(comicResponse.data!));
                final collectionJson = List<Map<String, dynamic>>.from(
                    jsonDecode(collectionResponse.data!));
                debugPrint(comicJson.toString());
                debugPrint(collectionJson.toString());

                for (var json in collectionJson) {
                  /*
                  e.g.
                  {
                    "name" : "History",
                    "id" : 1001,
                    "dateCreated" : 1693603899000
                  }
                  */
                  Store.collectComic(
                    collectionName: json['name'],
                    id: "${json['id']}",
                    dateCreated: DateTime.fromMillisecondsSinceEpoch(json['dateCreated']).toIso8601String(),
                  );
                }

                for (var json in comicJson) {
                  /* 
                  e.g. 
                  {
                    "id" : 1,
                    "mid" : "9",
                    "title" : "(C71) [Arisan-Antenna (Koari)] Eat The Rich! (Sukatto Golf Pangya)",
                    "pageTypes" : "jjjjjjjjjjjjjj",
                    "numOfPages" : 14
                  }
                  */

                  final result = await Store.addComic(
                    id: "${json['id']}",
                    mid: json['mid'],
                    title: json['title'],
                    images: json['pageTypes'],
                    pages: json['numOfPages'],
                  );
                  debugPrint("addcomic result for ${json['id']}: $result");
                }
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Open Source Licenses'),
              onTap: () {
                showLicensePage(context: context);
              },
            ),
          ]),
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
  final focusNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    // todo 20240313 try listen to the global focus change, unfocus when search bar's textfield is focused after returned
    // use some workaround like FocusScope.of(context).unfocus();
    WidgetsBinding.instance.focusManager.addListener(() {
      // debugPrint("Focused on ${WidgetsBinding.instance.focusManager.primaryFocus?.toStringDeep()}");
    });
  }

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
              title: FocusScope(
                node: focusNode,
                onFocusChange: (isFocused) {
                  debugPrint('focused $isFocused');
                  if (isFocused) {
                    focusNode.unfocus();
                  }
                },
                child: SearchAnchor.bar(
                  // barPadding: const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 160, vertical: 0)),
                  searchController: appModel.searchController,
                  onSubmitted: (value) {
                    Store.addSearchHistory(value);

                    // check if numeric, which means comic id
                    if (int.tryParse(value) != null) {
                      final id = value;
                      Provider.of<CurrentComicModel>(context, listen: false)
                          .fetchComic(id);
                      context
                          .push(Uri(path: '/third', queryParameters: {'id': id})
                              .toString())
                          .then((_) {
                        Provider.of<CurrentComicModel>(context, listen: false)
                            .clearComic();
                        appModel.searchController.text =
                            appModel.searchController.text;
                      });
                      return;
                    }

                    appModel.searchController.closeView(value);
                    if (appModel.navigationIndex != 0) {
                      appModel.navigationIndex = 0;
                    }

                    context.read<AppModel>().isLoading = true;
                    context
                        .read<ComicListModel>()
                        .fetchSearch(q: value, clearComic: true)
                        .then((value) =>
                            context.read<AppModel>().isLoading = false);
                    // Navigator.of(context).pop();
                  },
                  barTrailing: [
                    // todo 20240302 remove splash effect? like gmail thing
                    IconButton.filledTonal(
                      onPressed: () {
                        // todo 20240304 go to settings screen
                        context.push('/settings');
                      },
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
                      (BuildContext buildContext, SearchController controller) {
                    return Store.getSearchHistory()
                        .then((value) => value.map((e) => ListTile(
                              titleAlignment: ListTileTitleAlignment.center,
                              title: Text(e['query'] as String),
                              trailing: Text(DateTime.parse(
                                      "${e['created_at'] as String}Z")
                                  .toLocal()
                                  .toString()),
                              onTap: () {
                                // same with onSubmitted above
                                final value = e['query'] as String;
                                Store.addSearchHistory(value);

                                // check if numeric, which means comic id
                                if (int.tryParse(value) != null) {
                                  final id = value;
                                  Provider.of<CurrentComicModel>(context,
                                          listen: false)
                                      .fetchComic(id);
                                  context
                                      .push(Uri(
                                              path: '/third',
                                              queryParameters: {'id': id})
                                          .toString())
                                      .then((_) {
                                    Provider.of<CurrentComicModel>(context,
                                            listen: false)
                                        .clearComic();
                                    appModel.searchController.text =
                                        appModel.searchController.text;
                                  });
                                  return;
                                }

                                appModel.searchController.closeView(value);
                                if (appModel.navigationIndex != 0) {
                                  appModel.navigationIndex = 0;
                                }

                                context.read<AppModel>().isLoading = true;
                                context
                                    .read<ComicListModel>()
                                    .fetchSearch(q: value, clearComic: true)
                                    .then((value) => context
                                        .read<AppModel>()
                                        .isLoading = false);
                                // Navigator.of(context).pop();
                              },
                              onLongPress: () {
                                Store.deleteSearchHistory(e['query'] as String);
                                // touch appModel.searchController to refresh search history list
                                appModel.searchController.text =
                                    appModel.searchController.text;
                              },
                            )));
                  },
                ),
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
                pageLoaded: comicListModel.pageLoaded,
                collectionName: '#index',
              );
            },
          ),
          const CollectionSliver(
            collectionName: 'Favorite',
          ),
          /* 
          FutureBuilder(
            // todo 20240304 store future in state_model, refresh when clicked navigation bar
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
 */

          // SliverList(
          //   delegate: SliverChildListDelegate(
          //     [
          //       const Center(child: Text('Search')),
          //     ],
          //   ),
          // ),
          // Consumer<ComicListModel>(
          //   builder: (BuildContext context, ComicListModel comicListModel,
          //       Widget? child) {
          //     if (comicListModel.comics == null) {
          //       return SliverList(
          //         delegate: SliverChildListDelegate(
          //           [
          //             // const LinearProgressIndicator(),
          //           ],
          //         ),
          //       );
          //     }

          //     return ComicSliverGrid(
          //         comics: comicListModel.comics!
          //             .map((e) => ComicCover(
          //                   id: e.id!,
          //                   mediaId: e.mediaId!,
          //                   title: e.title!.english!,
          //                   images: e.images!,
          //                   pages: e.numPages!,
          //                   thumbnailExt: App.extMap[e.images!.thumbnail!.t!]!,
          //                   thumbnailWidth: e.images!.thumbnail!.w!,
          //                   thumbnailHeight: e.images!.thumbnail!.h!,
          //                 ))
          //             .toList(),
          //         comicsLoaded: comicListModel.comics!.length,
          //         pageLoaded: comicListModel.pageLoaded);
          //   },
          // ),
          CollectionListScreen(),
          // SliverList(
          //   delegate: SliverChildListDelegate(
          //     [
          //       const Center(child: Text('Settings')),
          //     ],
          //   ),
          // )
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
  final String collectionName;

  const ComicSliverGrid({
    super.key,
    required this.comics,
    required this.comicsLoaded,
    this.pageLoaded,
    required this.collectionName,
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
                        'Loading... page: ${pageLoaded! + 1}, language: ${NHLanguage.current.name}'),
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
            comic: comic,
            collectionName: collectionName,
          );
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
    required this.collectionName,
  });

  final String id;
  final String thumbnailLink;
  final int thumbnailWidth;
  final int thumbnailHeight;
  final String title;
  final String mid;
  final int pages;
  final ComicCover comic;
  final String collectionName;

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
              onTap: () {
                Provider.of<CurrentComicModel>(context, listen: false)
                    .fetchComic(id);
                context
                    .push(Uri(path: '/third', queryParameters: {'id': id})
                        .toString())
                    .then((_) =>
                        Provider.of<CurrentComicModel>(context, listen: false)
                            .clearComic());
              },
              onLongPress: () {
                // todo store collection name in upper state
                // pop up an dialog, if confirm, delete comic
                if (collectionName.isNotEmpty &&
                    !collectionName.startsWith('#')) {
                  showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title:
                              Text("Remove this comic from $collectionName?"),
                          content: Text(
                            "Careful! You can't undo this action. You are removing: $title",
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text('REMOVE'),
                              onPressed: () {
                                Store.uncollectComic(
                                  collectionName: collectionName,
                                  id: id,
                                );
                                context
                                    .read<ComicListModel>()
                                    .fetchEveryCollectionFuture();
                                // todo 20240324 consider to show a snackbar for "redo" delete

                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                          // children: [
                          //   SimpleDialogOption(
                          //     child: const Text('Yes'),
                          //     onPressed: () {
                          //       Store.uncollectComic(
                          //         collectionName: collectionName,
                          //         id: id,
                          //       );
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //           content: Text(
                          //             "Deleted from $collectionName, named $title",
                          //           ),
                          //         ),
                          //       );
                          //       debugPrint(
                          //         "comic $id removed from $collectionName",
                          //       );
                          //       Navigator.of(context).pop(true);
                          //     },
                          //   ),
                          //   SimpleDialogOption(
                          //     child: const Text('No'),
                          //     onPressed: () {
                          //       Navigator.of(context).pop(false);
                          //     },
                          //   ),
                          // ],
                        );
                      });
                }
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

                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added comic to Next'),
                  ),
                );
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

                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added comic to Favorite'),
                  ),
                );
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
                      debugPrint('debug clicked $collectionName');
                      context.push(
                        Uri(path: '/collection', queryParameters: {
                          'collectionName': collectionName
                        }).toString(),
                      );
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
    if (mid != "-1") {
      return "https://t.nhentai.net/galleries/$mid/thumb.$thumbnailExt";
    }

    return "https://placehold.co/${thumbnailWidth}x$thumbnailHeight/png?text=$collectionName";
  }

  CollectionCover({
    required this.collectionName,
    required this.collectedCount,
    required this.thumbnailExt,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.mid,
  });

  static CollectionCover emptyCollection({required String collectionName}) {
    return CollectionCover(
      mid: "-1",
      collectionName: collectionName,
      collectedCount: 0,
      thumbnailExt: "",
      thumbnailWidth: 720,
      thumbnailHeight: 720,
    );
  }

  @override
  String toString() {
    return 'CollectionCover{collectionName: $collectionName, collectedCount: $collectedCount}';
  }
}
