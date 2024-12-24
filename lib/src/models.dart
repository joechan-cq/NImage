import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
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

/// Structure of the request to load image sent to native
class LoadRequest {
  /// id of the texture created by native
  int textureId;

  /// image uri
  String? uri;

  /// the width of the output image, 0 means the original size, in pixels
  int width;

  /// the height of the output image, 0 means the original size, in pixels
  int height;

  BoxFit fit;

  LoadRequest({
    required this.textureId,
    this.uri,
    required this.width,
    required this.height,
    required this.fit,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['textureId'] = textureId;
    if (uri != null) {
      json['uri'] = uri;
    }
    json['width'] = width;
    json['height'] = height;
    json['fit'] = fit.name;
    return json;
  }
}

/// generate a unique key for NImageInfo
typedef KeyFactory = String Function(NImageInfo imageInfo);

KeyFactory _defaultFactory = (imageInfo) =>
    '${generateMd5(imageInfo.uri)}_${imageInfo.imageWidth}_${imageInfo.imageHeight}';

KeyFactory nImageKeyFactory = _defaultFactory;

class NImageInfo {
  /// image uri
  final String uri;

  /// width of image, unit: px
  final int imageWidth;

  /// height of image, unit: px
  final int imageHeight;

  NImageInfo({
    required this.uri,
    required this.imageWidth,
    required this.imageHeight,
  });

  static NImageInfo fromMap(Map<String, dynamic> map) {
    return NImageInfo(
      uri: map['uri'],
      imageWidth: map['imageWidth'],
      imageHeight: map['imageHeight'],
    );
  }

  @override
  String toString() {
    return 'imageWidth: $imageWidth imageHeight: $imageHeight';
  }

  bool get valid => imageWidth > 0 && imageHeight > 0;

  String get imageKey => nImageKeyFactory(this);
}
