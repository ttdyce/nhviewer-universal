class CFConfig{
  final int id;
  final String userAgent;
  final String token;

  const CFConfig({
    required this.id,
    required this.userAgent,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'useragent': userAgent,
      'token': token,
    };
  }
}

/// Code generated using [JSON to Dart converter](https://javiercbk.github.io/json_to_dart/) by Javier Lecuona. 
/// Note that id and mediaid could be both string and int
class NHComic {
  String? _id;
  String? _mediaId;
  Title? _title;
  Images? _images;
  String? _scanlator;
  int? _uploadDate;
  List<Tags>? _tags;
  int? _numPages;
  int? _numFavorites;

  NHComic(
      {String? id,
      String? mediaId,
      Title? title,
      Images? images,
      String? scanlator,
      int? uploadDate,
      List<Tags>? tags,
      int? numPages,
      int? numFavorites}) {
    if (id != null) {
      this._id = "$id";
    }
    if (mediaId != null) {
      this._mediaId = "$mediaId";
    }
    if (title != null) {
      this._title = title;
    }
    if (images != null) {
      this._images = images;
    }
    if (scanlator != null) {
      this._scanlator = scanlator;
    }
    if (uploadDate != null) {
      this._uploadDate = uploadDate;
    }
    if (tags != null) {
      this._tags = tags;
    }
    if (numPages != null) {
      this._numPages = numPages;
    }
    if (numFavorites != null) {
      this._numFavorites = numFavorites;
    }
  }

  String? get id => _id;
  set id(String? id) => _id = id;
  String? get mediaId => _mediaId;
  set mediaId(String? mediaId) => _mediaId = mediaId;
  Title? get title => _title;
  set title(Title? title) => _title = title;
  Images? get images => _images;
  set images(Images? images) => _images = images;
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
    _title = json['title'] != null ? new Title.fromJson(json['title']) : null;
    _images =
        json['images'] != null ? new Images.fromJson(json['images']) : null;
    _scanlator = json['scanlator'];
    _uploadDate = json['upload_date'];
    if (json['tags'] != null) {
      _tags = <Tags>[];
      json['tags'].forEach((v) {
        _tags!.add(new Tags.fromJson(v));
      });
    }
    _numPages = json['num_pages'];
    _numFavorites = json['num_favorites'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['media_id'] = this._mediaId;
    if (this._title != null) {
      data['title'] = this._title!.toJson();
    }
    if (this._images != null) {
      data['images'] = this._images!.toJson();
    }
    data['scanlator'] = this._scanlator;
    data['upload_date'] = this._uploadDate;
    if (this._tags != null) {
      data['tags'] = this._tags!.map((v) => v.toJson()).toList();
    }
    data['num_pages'] = this._numPages;
    data['num_favorites'] = this._numFavorites;
    return data;
  }
}

class Title {
  String? _english;
  String? _japanese;
  String? _pretty;

  Title({String? english, String? japanese, String? pretty}) {
    if (english != null) {
      this._english = english;
    }
    if (japanese != null) {
      this._japanese = japanese;
    }
    if (pretty != null) {
      this._pretty = pretty;
    }
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['english'] = this._english;
    data['japanese'] = this._japanese;
    data['pretty'] = this._pretty;
    return data;
  }
}

class Images {
  List<Pages>? _pages;
  Pages? _cover;
  Pages? _thumbnail;

  Images({List<Pages>? pages, Pages? cover, Pages? thumbnail}) {
    if (pages != null) {
      this._pages = pages;
    }
    if (cover != null) {
      this._cover = cover;
    }
    if (thumbnail != null) {
      this._thumbnail = thumbnail;
    }
  }

  List<Pages>? get pages => _pages;
  set pages(List<Pages>? pages) => _pages = pages;
  Pages? get cover => _cover;
  set cover(Pages? cover) => _cover = cover;
  Pages? get thumbnail => _thumbnail;
  set thumbnail(Pages? thumbnail) => _thumbnail = thumbnail;

  Images.fromJson(Map<String, dynamic> json) {
    if (json['pages'] != null) {
      _pages = <Pages>[];
      json['pages'].forEach((v) {
        _pages!.add(new Pages.fromJson(v));
      });
    }
    _cover = json['cover'] != null ? new Pages.fromJson(json['cover']) : null;
    _thumbnail = json['thumbnail'] != null
        ? new Pages.fromJson(json['thumbnail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._pages != null) {
      data['pages'] = this._pages!.map((v) => v.toJson()).toList();
    }
    if (this._cover != null) {
      data['cover'] = this._cover!.toJson();
    }
    if (this._thumbnail != null) {
      data['thumbnail'] = this._thumbnail!.toJson();
    }
    return data;
  }
}

class Pages {
  String? _t;
  int? _w;
  int? _h;

  Pages({String? t, int? w, int? h}) {
    if (t != null) {
      this._t = t;
    }
    if (w != null) {
      this._w = w;
    }
    if (h != null) {
      this._h = h;
    }
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['t'] = this._t;
    data['w'] = this._w;
    data['h'] = this._h;
    return data;
  }
}

class Tags {
  int? _id;
  String? _type;
  String? _name;
  String? _url;
  int? _count;

  Tags({int? id, String? type, String? name, String? url, int? count}) {
    if (id != null) {
      this._id = id;
    }
    if (type != null) {
      this._type = type;
    }
    if (name != null) {
      this._name = name;
    }
    if (url != null) {
      this._url = url;
    }
    if (count != null) {
      this._count = count;
    }
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['type'] = this._type;
    data['name'] = this._name;
    data['url'] = this._url;
    data['count'] = this._count;
    return data;
  }
}