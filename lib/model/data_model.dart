/// Data models for nhentai API v2 and legacy DB format by copilot.
/// Note that id and mediaid could be both string and int

/// CDN server configuration from /api/v2/cdn
class NHCdnConfig {
  List<String> imageServers;
  List<String> thumbServers;

  NHCdnConfig({required this.imageServers, required this.thumbServers});

  NHCdnConfig.fromJson(Map<String, dynamic> json)
      : imageServers = List<String>.from(json['image_servers']),
        thumbServers = List<String>.from(json['thumb_servers']);

  String get imageServer => imageServers.isNotEmpty ? imageServers[0] : 'https://i3.nhentai.net';
  String get thumbServer => thumbServers.isNotEmpty ? thumbServers[0] : 'https://t3.nhentai.net';
}

/// Paginated response from v2 search/galleries endpoints
class NHList {
  List<NHComic>? result;
  int? numPages;
  int? perPage;

  NHList({this.result, this.numPages, this.perPage});

  NHList.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <NHComic>[];
      json['result'].forEach((v) {
        result!.add(NHComic.fromJson(v));
      });
    }
    numPages = json['num_pages'];
    perPage = json['per_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    data['num_pages'] = numPages;
    data['per_page'] = perPage;
    return data;
  }
}

/// Unified comic model supporting:
/// - v2 GalleryListItem (from search results - lightweight)
/// - v2 GalleryDetailResponse (from gallery detail - full)
/// - Legacy DB format (old images JSON)
class NHComic {
  String? _id;
  String? _mediaId;
  Title? _title;
  NHImages? _images; // Legacy: from old API / DB
  String? _scanlator;
  int? _uploadDate;
  List<Tags>? _tags;
  int? _numPages;
  int? _numFavorites;

  // v2 fields
  String? thumbnailUrl;   // Direct thumbnail path from v2 API
  int? thumbnailWidth;    // From v2 GalleryListItem or CoverInfo
  int? thumbnailHeight;   // From v2 GalleryListItem or CoverInfo
  List<NHPageInfo>? pageInfos; // From v2 GalleryDetailResponse
  NHCoverInfo? coverInfo;      // From v2 GalleryDetailResponse

  NHComic(
      {String? id,
      String? mediaId,
      Title? title,
      NHImages? images,
      String? scanlator,
      int? uploadDate,
      List<Tags>? tags,
      int? numPages,
      int? numFavorites}) {
    if (id != null) _id = "$id";
    if (mediaId != null) _mediaId = "$mediaId";
    if (title != null) _title = title;
    if (images != null) _images = images;
    if (scanlator != null) _scanlator = scanlator;
    if (uploadDate != null) _uploadDate = uploadDate;
    if (tags != null) _tags = tags;
    if (numPages != null) _numPages = numPages;
    if (numFavorites != null) _numFavorites = numFavorites;
  }

  String? get id => _id;
  set id(String? id) => _id = id;
  String? get mediaId => _mediaId;
  set mediaId(String? mediaId) => _mediaId = mediaId;
  Title? get title => _title;
  set title(Title? title) => _title = title;
  NHImages? get images => _images;
  set images(NHImages? images) => _images = images;
  String? get scanlator => _scanlator;
  set scanlator(String? scanlator) => _scanlator = scanlator;
  int? get uploadDate => _uploadDate;
  set uploadDate(int? uploadDate) => _uploadDate = uploadDate;
  List<Tags>? get tags => _tags;
  set tags(List<Tags>? tags) => _tags = tags;
  int? get numPages => _numPages;
  set numPages(int? numPages) => _numPages = numPages;
  int? get numFavorites => _numFavorites;
  set numFavorites(int? numFavorites) => _numFavorites = numFavorites;

  NHComic.fromJson(Map<String, dynamic> json) {
    _id = "${json['id']}";
    _mediaId = "${json['media_id']}";

    if (json['english_title'] != null) {
      // v2 GalleryListItem format (from search/galleries list)
      _title = Title(
        english: json['english_title'],
        japanese: json['japanese_title'],
        pretty: json['english_title'],
      );
      thumbnailUrl = json['thumbnail'];
      thumbnailWidth = json['thumbnail_width'];
      thumbnailHeight = json['thumbnail_height'];
      _numPages = json['num_pages'] ?? 0;
    } else {
      // v2 GalleryDetailResponse or legacy format
      _title = json['title'] != null ? Title.fromJson(json['title']) : null;
      _scanlator = json['scanlator'];
      _uploadDate = json['upload_date'];
      if (json['tags'] != null) {
        _tags = <Tags>[];
        json['tags'].forEach((v) {
          _tags!.add(Tags.fromJson(v));
        });
      }
      _numPages = json['num_pages'];
      _numFavorites = json['num_favorites'];

      // Detect v2 detail format (has cover as {path, width, height})
      if (json['cover'] is Map && json['cover']['path'] != null) {
        coverInfo = NHCoverInfo.fromJson(json['cover']);
        if (json['thumbnail'] is Map && json['thumbnail']['path'] != null) {
          final thumbInfo = NHCoverInfo.fromJson(json['thumbnail']);
          thumbnailUrl = thumbInfo.path;
          thumbnailWidth = thumbInfo.width;
          thumbnailHeight = thumbInfo.height;
        }
        if (json['pages'] != null) {
          pageInfos = <NHPageInfo>[];
          for (var p in json['pages']) {
            pageInfos!.add(NHPageInfo.fromJson(p));
          }
        }
      } else if (json['images'] != null) {
        // Legacy format with images: {pages, cover, thumbnail}
        _images = NHImages.fromJson(json['images']);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = _id;
    data['media_id'] = _mediaId;
    if (_title != null) data['title'] = _title!.toJson();
    if (_images != null) data['images'] = _images!.toJson();
    data['scanlator'] = _scanlator;
    data['upload_date'] = _uploadDate;
    if (_tags != null) data['tags'] = _tags!.map((v) => v.toJson()).toList();
    data['num_pages'] = _numPages;
    data['num_favorites'] = _numFavorites;
    return data;
  }

  /// Serialize image info for DB storage (v2 format)
  String toImagesJsonForDb() {
    final Map<String, dynamic> data = {'v2': true};
    if (thumbnailUrl != null) {
      data['thumbnail'] = {
        'path': thumbnailUrl,
        'width': thumbnailWidth,
        'height': thumbnailHeight,
      };
    }
    if (coverInfo != null) {
      data['cover'] = {
        'path': coverInfo!.path,
        'width': coverInfo!.width,
        'height': coverInfo!.height,
      };
    }
    if (pageInfos != null) {
      data['pages'] = pageInfos!.map((p) => p.toJson()).toList();
    }
    return data.toString();
  }
}

/// Cover/thumbnail info from v2 GalleryDetailResponse
class NHCoverInfo {
  String? path;
  int? width;
  int? height;

  NHCoverInfo({this.path, this.width, this.height});

  NHCoverInfo.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    width = json['width'];
    height = json['height'];
  }
}

/// Page info from v2 GalleryDetailResponse
class NHPageInfo {
  int? number;
  String? path;
  int? width;
  int? height;
  String? thumbnail;
  int? thumbnailWidth;
  int? thumbnailHeight;

  NHPageInfo({this.number, this.path, this.width, this.height});

  NHPageInfo.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    path = json['path'];
    width = json['width'];
    height = json['height'];
    thumbnail = json['thumbnail'];
    thumbnailWidth = json['thumbnail_width'];
    thumbnailHeight = json['thumbnail_height'];
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'path': path,
      'width': width,
      'height': height,
      'thumbnail': thumbnail,
      'thumbnail_width': thumbnailWidth,
      'thumbnail_height': thumbnailHeight,
    };
  }
}

class Title {
  String? _english;
  String? _japanese;
  String? _pretty;

  Title({String? english, String? japanese, String? pretty}) {
    if (english != null) _english = english;
    if (japanese != null) _japanese = japanese;
    if (pretty != null) _pretty = pretty;
  }

  String? get english => _english;
  set english(String? english) => _english = english;
  String? get japanese => _japanese;
  set japanese(String? japanese) => _japanese = japanese;
  String? get pretty => _pretty;
  set pretty(String? pretty) => _pretty = pretty;

  Title.fromJson(Map<String, dynamic> json) {
    _english = json['english'];
    _japanese = json['japanese'];
    _pretty = json['pretty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['english'] = _english;
    data['japanese'] = _japanese;
    data['pretty'] = _pretty;
    return data;
  }
}

/// Legacy image structure from old API. Kept for backward compatibility
/// with existing comics stored in the local database.
class NHImages {
  List<Pages>? _pages;
  Pages? _cover;
  Pages? _thumbnail;

  NHImages({List<Pages>? pages, Pages? cover, Pages? thumbnail}) {
    if (pages != null) _pages = pages;
    if (cover != null) _cover = cover;
    if (thumbnail != null) _thumbnail = thumbnail;
  }

  List<Pages>? get pages => _pages;
  set pages(List<Pages>? pages) => _pages = pages;
  Pages? get cover => _cover;
  set cover(Pages? cover) => _cover = cover;
  Pages? get thumbnail => _thumbnail;
  set thumbnail(Pages? thumbnail) => _thumbnail = thumbnail;

  NHImages.fromJson(Map<String, dynamic> json) {
    if (json['pages'] != null) {
      _pages = <Pages>[];
      json['pages'].forEach((v) {
        _pages!.add(Pages.fromJson(v));
      });
    }
    _cover = json['cover'] != null ? Pages.fromJson(json['cover']) : null;
    _thumbnail = json['thumbnail'] != null
        ? Pages.fromJson(json['thumbnail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (_pages != null) {
      data['pages'] = _pages!.map((v) => v.toJson()).toList();
    }
    if (_cover != null) {
      data['cover'] = _cover!.toJson();
    }
    if (_thumbnail != null) {
      data['thumbnail'] = _thumbnail!.toJson();
    }
    return data;
  }
}

/// Legacy page type info (t=type code, w=width, h=height)
class Pages {
  String? _t;
  int? _w;
  int? _h;

  Pages({String? t, int? w, int? h}) {
    if (t != null) _t = t;
    if (w != null) _w = w;
    if (h != null) _h = h;
  }

  String? get t => _t;
  set t(String? t) => _t = t;
  int? get w => _w;
  set w(int? w) => _w = w;
  int? get h => _h;
  set h(int? h) => _h = h;

  Pages.fromJson(Map<String, dynamic> json) {
    _t = json['t'];
    _w = json['w'];
    _h = json['h'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['t'] = _t;
    data['w'] = _w;
    data['h'] = _h;
    return data;
  }
}

/// Tag info from v2 TagResponse (also backward compatible with old format)
class Tags {
  int? _id;
  String? _type;
  String? _name;
  String? _url;
  int? _count;

  Tags({int? id, String? type, String? name, String? url, int? count}) {
    if (id != null) _id = id;
    if (type != null) _type = type;
    if (name != null) _name = name;
    if (url != null) _url = url;
    if (count != null) _count = count;
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get type => _type;
  set type(String? type) => _type = type;
  String? get name => _name;
  set name(String? name) => _name = name;
  String? get url => _url;
  set url(String? url) => _url = url;
  int? get count => _count;
  set count(int? count) => _count = count;

  Tags.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _type = json['type'];
    _name = json['name'];
    _url = json['url'];
    _count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = _id;
    data['type'] = _type;
    data['name'] = _name;
    data['url'] = _url;
    data['count'] = _count;
    return data;
  }
}