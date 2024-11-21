import 'package:nimage/src/cache/lrucache.dart';
import 'package:nimage/src/image_widget.dart';
import 'package:nimage/src/imageinfo.dart';

class TextureInfo {
  double width;
  double height;
  int textureId;
  String imageKey;
  NImageInfo? imageInfo;

  TextureInfo({
    required this.width,
    required this.height,
    required this.textureId,
    required this.imageKey,
    this.imageInfo,
  });

  @override
  bool operator ==(Object other) {
    if (other is! TextureInfo) {
      return false;
    }
    return width == other.width &&
        height == other.height &&
        textureId == other.textureId &&
        imageKey == other.imageKey;
  }

  @override
  String toString() {
    return 'textureId:$textureId, imagekey:$imageKey, imageInfo:$imageInfo';
  }

}

class _Pair<E, F> {
  E first;
  F second;

  _Pair(this.first, this.second);

  @override
  String toString() {
    return '\nfirst:$first\nsecond:$second';
  }
}

class ImageTextureCache {
  /// 最大LruCache缓存大小（默认情况下表示数量）
  static int maxCacheSize = 20;
  /// 存储Texture纹理的LruCache缓存
  late final LruCache<String, TextureInfo> _textureLruCache;

  /// Texture纹理引用计数
  late final Map<String, _Pair<TextureInfo, int>> _textureReferences;

  factory ImageTextureCache() => _getInstance();

  static ImageTextureCache get instance => _getInstance();
  static ImageTextureCache? _instance;

  static ImageTextureCache _getInstance() {
    _instance ??= ImageTextureCache._internal();
    return _instance!;
  }

  ImageTextureCache._internal() {
    _textureReferences = {};
    _textureLruCache = LruCache<String, TextureInfo>(
      maxSize: maxCacheSize,
      onEntryRemoveCallback: (bool evict, String key, TextureInfo value) {
        _onImageTextureRemoved(evict, key, value);
      },
    );
  }

  TextureInfo? findImageTextureWithData(String data) {
    String keyPrefix = data;

    try {
      MapEntry<String, _Pair<TextureInfo, int>> entry = _textureReferences.entries.firstWhere((MapEntry<String, _Pair<TextureInfo, int>> entry) {
        return entry.key.startsWith(keyPrefix);
      });
      if (entry.value != null && entry.value.first != null) {
        return entry.value.first;
      }
    } on StateError {}

    try {
      MapEntry<String, TextureInfo> entry = _textureLruCache.entries.firstWhere((MapEntry<String, TextureInfo> entry) {
        return entry.key.startsWith(keyPrefix);
      });
      return entry.value;
    } on StateError {}

    return null;
  }

  ///
  /// 获取缓存的Texture数据
  ///
  TextureInfo? getImageTexture(double width, double height, String imageKey) {
    String key = _createKey(width: width, height: height, imageKey: imageKey);
    TextureInfo? textureInfo = _textureReferences[key]?.first;
    textureInfo ??= _textureLruCache[key];
    return textureInfo;
  }

  /// 获取指定TextureInfo的引用计数
  int? getRefCount(TextureInfo textureInfo) {
    String key = _createKey(textureInfo: textureInfo);
    _Pair<TextureInfo, int>? pair = _textureReferences[key];
    return pair?.second;
  }

  void increaseRefByTextureId(int textureId) {
    try {
      var entry = _textureReferences.entries.firstWhere((entry) {
        return entry.value.first.textureId == textureId;
      });
      entry.value.second += 1;
    } on StateError catch (ignore) {
      //说明Ref中没有找到，那么如果LruCache中有，那么需要移除掉
      try {
        var entry = _textureLruCache.entries
            .firstWhere((entry) => entry.value.textureId == textureId);
        var key = entry.key;
        TextureInfo textureInfo = entry.value;
        _textureLruCache.remove(key);
        _textureReferences[key] = _Pair(textureInfo, 1);
      } on StateError catch (ignore) {}
    }
  }

  void decreaseRefByTextureId(int textureId) {
    try {
      var entry = _textureReferences.entries.firstWhere((entry) {
        return entry.value.first.textureId == textureId;
      });
      entry.value.second -= 1;
      if (entry.value.second == 0) {
        _textureReferences.remove(entry.key);
      }
      _textureLruCache.putIfAbsent(entry.key, () => entry.value.first);
    } on StateError catch (ignore) {}
  }

  ///
  /// 增加引用计数
  ///
  void increaseRef(TextureInfo textureInfo) {
    String key = _createKey(textureInfo: textureInfo);
    _Pair<TextureInfo, int>? pair = _textureReferences[key];
    if (pair == null) {
      _textureLruCache.remove(key);
      if (NImage.debug) {
        print('$textureInfo is removed from Lrucache');
      }
    }
    pair ??= _Pair(textureInfo, 0);
    pair.second += 1;
    _textureReferences[key] = pair;
  }

  ///
  /// 减少引用计数
  ///
  void decreaseRef(TextureInfo textureInfo) {
    String key = _createKey(textureInfo: textureInfo);
    _Pair<TextureInfo, int>? pair = _textureReferences[key];
    if (pair != null) {
      pair.second -= 1;
      if (pair.second == 0) {
        //如果引用计数减到了0，那么加入LruCache缓存队列
        _textureLruCache.putIfAbsent(key, () => textureInfo);
        if (NImage.debug) {
          print('$textureInfo is added to Lrucache');
        }
        _textureReferences.remove(key);
      }
    }
    if (NImage.debug) {
      if (_textureReferences.isEmpty) {
        print('textureReferences is empty now!');
      }
    }
  }

  void clearLruCache() {
    _textureLruCache.clear();
  }

  String _createKey({
    TextureInfo? textureInfo,
    double? width,
    double? height,
    String? imageKey,
  }) {
    if (textureInfo != null) {
      return '${textureInfo.imageKey}-w${textureInfo.width}-h${textureInfo
          .height}';
    } else {
      return '$imageKey-w$width-h$height';
    }
  }

  static void _onImageTextureRemoved(bool evict, String key,
      TextureInfo value) {
    if (evict) {
      NImageChannel.disposeTexture(value.textureId);
    }
  }
}
