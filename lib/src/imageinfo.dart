import 'dart:convert';

import 'package:crypto/crypto.dart';

String generateMd5(String data) {
  var content = utf8.encoder.convert(data);
  var digest = md5.convert(content);
  return digest.toString();
}

///给NImageInfo生成唯一Key的方法
typedef KeyFactory = String Function(NImageInfo imageInfo);

KeyFactory _defaultFactory = (imageInfo) =>
    '${generateMd5(imageInfo.uri)}_${imageInfo.imageWidth}_${imageInfo.imageHeight}';

KeyFactory nImageKeyFactory = _defaultFactory;

class NImageInfo {
  /// 图片uri
  final String uri;

  /// 图片宽度
  final int imageWidth;

  /// 图片高度
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
}
