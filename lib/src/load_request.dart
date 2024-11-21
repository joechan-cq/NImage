///
/// 发送给Native的加载请求
///
class LoadRequest {
  /// Native创建用于显示图片的Texture
  int textureId;

  /// 图片加载url
  String? uri;

  /// 图片输出dstWidth，0表示原图大小
  int? width;

  /// 图片输出dstHeight，0表示原图大小
  int? height;

  LoadRequest({
    required this.textureId,
    this.uri,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['textureId'] = textureId;
    if (uri != null) {
      json['uri'] = uri;
    }
    if (width != null) {
      json['width'] = width;
    }
    if (height != null) {
      json['height'] = height;
    }
    return json;
  }
}
