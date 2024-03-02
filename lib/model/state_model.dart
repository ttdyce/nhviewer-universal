import 'dart:convert';
import 'dart:io';

import 'package:concept_nhv/main.dart';
import 'package:concept_nhv/model/data_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  int _navigationIndex = 0;
  final searchController = SearchController();

  int get navigationIndex => _navigationIndex;
  set navigationIndex(int value) {
    _navigationIndex = value;
    if (value != 2) {
      searchController.text = '';
    }
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class ComicListModel extends ChangeNotifier {
  final List<NHList> _fetchedComics = [];
  final List<Map<String, Object?>> everyCollection = [];

  // todo 20240211 is exposing $page problematic?
  int pageLoaded = 1;
  bool _noMorePage = false;

  bool get noMorePage => _noMorePage;

  Function? _fetchPage;

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
    bool clearComic = false,
  }) async {
    if (clearComic) {
      _fetchedComics.clear();
    }

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
      final freshComics = NHList.fromJson(response.data);
      print(response);
      _fetchedComics.add(freshComics);
      // This call tells the widgets that are listening to this model to rebuild.
      notifyListeners();
      _fetchPage = (p) => fetchIndex(
            page: p,
            language: language,
            sortByPopularType: sortByPopularType,
          );
      _noMorePage = freshComics.result?.isEmpty ?? true;
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

  // fetchFavorite() {}

  fetchCollections() async {
    everyCollection.clear();
    everyCollection.addAll(await Store.getEveryCollection());
    notifyListeners();
  }

  fetchSearch(String q,
      {int page = 1,
      String? language,
      String? sortByPopularType = NHPopularType.allTime,
      int retryCount = 0,
      bool clearComic = false}) async {
    if (clearComic) {
      _fetchedComics.clear();
    }

    if (retryCount > 1) {
      debugPrint("fetchSearch retried 2 times, giving up");
      return;
    }

    language = language ?? NHLanguage.currentSetting;
    final (agent, token) = await Store.getCFCookie();
    var url =
        "https://nhentai.net/api/galleries/search?query=$q%20$language&page=$page";
    if (sortByPopularType != null) {
      url += "&sort=$sortByPopularType";
    }

    final dio = Dio();
    debugPrint('Loading search: $url');
    try {
      final response = await dio.get(url,
          options: Options(headers: {
            HttpHeaders.userAgentHeader: agent,
            HttpHeaders.cookieHeader: "cf_clearance=$token",
          }));
      final freshComics = NHList.fromJson(response.data);
      print(response);
      _fetchedComics.add(freshComics);
      // todo 20240227 it is known that when reaching last page (when freshComics is empty, i.e. {"result":[],"num_pages":2,"per_page":25}), it is rebuilding one more time. Tiny performance issue
      // This call tells the widgets that are listening to this model to rebuild.
      notifyListeners();
      _fetchPage = (p) => fetchSearch(
            q,
            page: p,
            language: language,
            sortByPopularType: sortByPopularType,
          );
      _noMorePage = freshComics.result?.isEmpty ?? true;
    } catch (e) {
      print(e);
      debugPrint('Loading search failed ($url), retrying...');
      if (language == NHLanguage.chinese) {
        language = NHLanguage.chinese2;
        NHLanguage.currentSetting = language;
      }
      fetchSearch(
        q,
        page: page,
        language: language,
        sortByPopularType: sortByPopularType,
        retryCount: retryCount + 1,
      );
    }

    pageLoaded = page;
  }

  Future<void> fetchPage({required int page}) => _fetchPage?.call(page);
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
