import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:nimage/src/cache/texture_cache_mgr.dart';

String generateMd5(String data) {
  var content = utf8.encoder.convert(data);
  var digest = md5.convert(content);
  return digest.toString();
}

class LoadWorker {
  int? textureId;
  LoadRequest? request;
  String? requestKey;
  NImageInfo? imageInfo;
  TextureInfo? textureInfo;
}

///
/// 发送给Native的加载请求
///
class LoadRequest {
  /// Native创建用于显示图片的Texture
  int textureId;

  /// 图片加载url
  String? uri;

  /// 图片输出dstWidth，0表示原图大小，单位px
  int width;

  /// 图片输出dstHeight，0表示原图大小，单位px
  int height;

  LoadRequest({
    required this.textureId,
    this.uri,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['textureId'] = textureId;
    if (uri != null) {
      json['uri'] = uri;
    }
    json['width'] = width;
    json['height'] = height;
    return json;
  }
}

///给NImageInfo生成唯一Key的方法
typedef KeyFactory = String Function(NImageInfo imageInfo);

KeyFactory _defaultFactory = (imageInfo) =>
    '${generateMd5(imageInfo.uri)}_${imageInfo.imageWidth}_${imageInfo.imageHeight}';

KeyFactory nImageKeyFactory = _defaultFactory;

class NImageInfo {
  /// 图片uri
  final String uri;

  /// 图片宽度，单位px
  final int imageWidth;

  /// 图片高度，单位px
  final int imageHeight;

  /// 图片的本地缓存路径
  final String? cachePath;

  NImageInfo({
    required this.uri,
    required this.imageWidth,
    required this.imageHeight,
    this.cachePath,
  });

  static NImageInfo fromMap(Map<String, dynamic> map) {
    return NImageInfo(
      uri: map['uri'],
      imageWidth: map['imageWidth'],
      imageHeight: map['imageHeight'],
      cachePath: map['cachePath'],
    );
  }

  @override
  String toString() {
    return 'imageWidth: $imageWidth imageHeight: $imageHeight cachePath: $cachePath';
  }

  bool get valid => imageWidth > 0 && imageHeight > 0;

  String get imageKey => nImageKeyFactory(this);
}
