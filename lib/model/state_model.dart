import 'dart:convert';
import 'dart:io';

import 'package:concept_nhv/main.dart';
import 'package:concept_nhv/model/data_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  int _navigationIndex = 0;
  final searchController = SearchController();

  int get navigationIndex => _navigationIndex;
  set navigationIndex(int value) {
    final doubleClickIndex = _navigationIndex == 0 && value == 0;
    final fromIndexPage = navigationIndex == 0;
    if (doubleClickIndex || fromIndexPage) {
      searchController.text = '';
    }
    _navigationIndex = value;
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
  Future<List<Map<String, Object?>>>? everyCollectionFuture;

  // todo 20240211 is exposing $page problematic?
  int pageLoaded = 1;
  bool _noMorePage = false;
  bool get noMorePage => _noMorePage;
  String? _sortByPopularType;

  String? get sortByPopularType => _sortByPopularType;

  set sortByPopularType(String? value) {
    _sortByPopularType = value;
  }

  Function? _fetchPage;

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

  void fetchEveryCollectionFuture(){
    everyCollectionFuture = Store.getEveryCollection();
    notifyListeners();
  }

  Future<int?> fetchIndex({
    int page = 1,
    // String? sortByPopularType,
    bool clearComic = false,
  }) =>
      fetchSearch(
        q: '',
        page: page,
        // sortByPopularType: sortByPopularType,
        clearComic: clearComic,
      );

  /// Fetch search result with query [q] and page [page]. If [clearComic] is
  /// true, clear the current search result before fetching. If [retryCount]
  /// is non-zero, it means this function is being called recursively to
  /// retry the search with alternative language query. If [lastStatusCode] is
  /// non-null, use it as the last status code of the previous search
  /// request.
  Future<int?> fetchSearch({
    required String q,
    int page = 1,
    String? sortByPopularType,
    int retryCount = 0,
    bool clearComic = false,
    int? lastStatusCode,
  }) async {
    if (clearComic) {
      _fetchedComics.clear();
    }

    if (retryCount > NHLanguage.current.alternatives.length) {
      debugPrint("fetchSearch retried $retryCount times, giving up");
      return lastStatusCode;
    }

    var languageQuery = NHLanguage.current.queryString;
    if (retryCount > 0) {
      languageQuery = NHLanguage.current.alternatives[retryCount - 1];
    }

    var url =
        "https://nhentai.net/api/galleries/search?query=$q%20$languageQuery&page=$page";
    if (sortByPopularType != null) {
      _sortByPopularType = sortByPopularType;
      url += "&sort=$sortByPopularType";
    } else if (this.sortByPopularType != null) {
      url += "&sort=${this.sortByPopularType}";
    }

    final dio = Dio();
    if (q.isEmpty) {
      debugPrint('Loading index (empty search): $url');
    } else {
      debugPrint('Loading search: $url');
    }
    
    // Try request without options first
    try {
      debugPrint('Trying request without headers...');
      final response = await dio.get(url);
      print(response);
      final freshComics = NHList.fromJson(response.data);
      _noMorePage = freshComics.result?.isEmpty ?? true;
      lastStatusCode = response.statusCode;
      if (!_noMorePage) {
        _fetchedComics.add(freshComics);
      }
      // todo 20240227 Tiny performance issue: it is known that when reaching last page (when freshComics is empty, i.e. {"result":[],"num_pages":2,"per_page":25}), it is rebuilding one more time.
      // This call tells the widgets that are listening to this model to rebuild.
      notifyListeners();
      _fetchPage = (p, clearComic) => fetchSearch(
            q: q,
            page: p,
            sortByPopularType: sortByPopularType,
            retryCount: retryCount,
            clearComic: clearComic,
          );
    } on DioException catch (e) {
      debugPrint(
          "fetchSearch failed without headers, status code = ${e.response?.statusCode}");
      debugPrint('Trying with headers...');
      
      // Get cookies only when needed
      final (agent, token) = await Store.getCFCookies();
      
      // Try with headers if the first attempt fails
      try {
        final response = await dio.get(url,
            options: Options(headers: {
              HttpHeaders.userAgentHeader: agent,
              HttpHeaders.cookieHeader: "cf_clearance=$token",
            }));
        print(response);
        final freshComics = NHList.fromJson(response.data);
        _noMorePage = freshComics.result?.isEmpty ?? true;
        lastStatusCode = response.statusCode;
        if (!_noMorePage) {
          _fetchedComics.add(freshComics);
        }
        notifyListeners();
        _fetchPage = (p, clearComic) => fetchSearch(
              q: q,
              page: p,
              sortByPopularType: sortByPopularType,
              retryCount: retryCount,
              clearComic: clearComic,
            );
      } on DioException catch (e2) {
        debugPrint(
            "fetchSearch DioException with headers, status code = ${e2.response?.statusCode}");
        debugPrint('fetchSearch failed ($url), retrying...');
        return fetchSearch(
          q: q,
          page: page,
          sortByPopularType: sortByPopularType,
          retryCount: retryCount + 1,
          lastStatusCode: e2.response?.statusCode,
          clearComic: true,
        );
      }
    }

    pageLoaded = page;
    return lastStatusCode;
  }

  Future<void> fetchPage({int? page}) {
    if (page == null) return _fetchPage?.call(1, true);
    return _fetchPage?.call(page, false);
  }
}

class CurrentComicModel extends ChangeNotifier {
  ScrollController scrollController = ScrollController();
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
    final dio = Dio();
    
    // Try request without headers first
    try {
      debugPrint('Trying fetchComic without headers...');
      final response = await dio.get('https://nhentai.net/api/gallery/$id');
      print(response);
      currentComic = NHComic.fromJson(response.data);
      headers = null; // No headers needed
      notifyListeners();
    } catch (e) {
      debugPrint('fetchComic failed without headers, trying with headers...');
      
      // Get cookies only when needed
      final (agent, token) = await Store.getCFCookies();
      
      headers = {
        HttpHeaders.userAgentHeader: agent,
        HttpHeaders.cookieHeader: "cf_clearance=$token",
      };
      
      // Try with headers if the first attempt fails
      try {
        final response = await dio.get('https://nhentai.net/api/gallery/$id',
            options: Options(headers: headers));
        print(response);
        currentComic = NHComic.fromJson(response.data);
        notifyListeners();
      } catch (e2) {
        print('fetchComic failed with headers: $e2');
        rethrow;
      }
    }
  }

  void clearComic() {
    currentComic = null;
    // notifyListeners();
  }
}
