import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:nimage/src/cache/texture_cache_mgr.dart';
import 'package:nimage/src/models.dart';
import 'package:nimage/src/nimage_channel.dart';

class _Pair<F, S> {
  F? first;
  S? second;

  _Pair([this.first, this.second]);
}

class NImage extends StatelessWidget {
  /// whether to print debug log
  static bool debug = false;

  ///Widget width
  final double? width;

  ///Widget height
  final double? height;

  ///placeHolder Widget when loading
  final Widget? placeHolder;

  ///error Widget if error occurred
  final ImageErrorWidgetBuilder? errorBuilder;

  final String? src;

  const NImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.placeHolder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (src?.isEmpty ?? true) {
      if (errorBuilder != null) {
        return errorBuilder!(context, 'load src is null', null);
      } else {
        return SizedBox(width: width, height: height);
      }
    }
    return LayoutBuilder(builder: (ctx, cs) {
      return Container();
    });
  }
}

class NImageTexture extends StatefulWidget {
  final String uri;
  final double? width;
  final double? height;

  const NImageTexture({
    super.key,
    required this.uri,
    this.width,
    this.height,
  });

  @override
  State<NImageTexture> createState() => _NImageTextureState();
}

class _NImageTextureState extends State<NImageTexture> {
  late bool _loading;
  late bool _error;

  late String _uri;
  late double _textureWidth;
  late double _textureHeight;
  LoadRequest? _request;

  /// current image texture bound with State
  TextureInfo? _textureInfo;

  @override
  void initState() {
    super.initState();
    _uri = widget.uri;
    _textureWidth = widget.width ?? 0;
    _textureHeight = widget.height ?? 0;
    _loading = true;
    _error = false;
    _load();
  }

  @override
  void didUpdateWidget(covariant NImageTexture oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  void _load() {
    //try to find the cached texture.
    _textureInfo = ImageTextureCache.instance
        .getImageTexture(_uri, _textureWidth, _textureHeight);
    if (_textureInfo != null) {
      if (NImage.debug) {
        print('find texture from cache: ${_textureInfo!.textureId}');
      }
      _showExistedTexture();
    } else {
      //load by native
      //create texture first.
      LoadWorker w = LoadWorker();
      _createTexture(w).then((worker) async {
        assert(worker.textureId != null);
        if (!mounted) {
          //the case occurs when listview scroll quickly.
          NImageChannel.destroyTexture(worker.textureId!);
          return null;
        }
        if (NImage.debug) {
          print('create new texture: ${worker.textureId}');
        }
        //call native to load image.
        return _nativeLoadImage(worker);
      }).then((worker) {
        //acquire imageInfo from native.
        //by now the image has been drawn on texture.
        if (worker != null) {
          int tid = worker.textureId!;
          NImageInfo? imageInfo = worker.imageInfo;
          if (imageInfo != null) {
            TextureInfo textureInfo = TextureInfo(
              width: _textureWidth,
              height: _textureHeight,
              textureId: tid,
              imageKey: imageInfo.imageKey,
              imageInfo: imageInfo,
            );
            worker.textureInfo = textureInfo;
            // put the texture to cache
            _saveTextureInfo(worker);
          }
        }
      });
    }
  }

  Future<LoadWorker> _createTexture(LoadWorker worker) {
    return NImageChannel.createTexture().then((tid) {
      worker.textureId = tid;
      return worker;
    });
  }

  Future<LoadWorker> _nativeLoadImage(LoadWorker worker) {
    assert(worker.textureId != null);
    int widthPx = 0, heightPx = 0;
    widthPx = (window.devicePixelRatio * _textureWidth).toInt();
    heightPx = (window.devicePixelRatio * _textureHeight).toInt();
    worker.requestKey = _loadRequestKey();
    LoadRequest request = LoadRequest(
      textureId: worker.textureId!,
      uri: _uri,
      width: widthPx,
      height: heightPx,
    );
    return NImageChannel.loadImage(request).then((imageInfo) {
      worker.imageInfo = imageInfo;
      return worker;
    });
  }

  void _saveTextureInfo(LoadWorker worker) {
    assert(worker.textureInfo != null);
    if (worker.requestKey != _loadRequestKey()) {
      //it means that current _NImageTextureState has been updated and reused.
      //and the new request doesn't match the old one.
      //just put the texture into LruCache.
      ImageTextureCache.instance.addTextureInfo2LruCache(worker.textureInfo!);
    } else {
      
    }
  }

  String _loadRequestKey() {
    return '$_uri-$_textureWidth-$_textureHeight';
  }

  void _showExistedTexture() {
    _loading = false;
    _error = false;
    int count = ImageTextureCache.instance.increaseRef(_textureInfo!);
    if (NImage.debug) {
      print(
          'increaseRef imageTexture for existedTexture, now ref-count: $count');
    }
    callImageVisible();
  }

  void callImageVisible() {
    if (_textureInfo?.textureId != null) {
      NImageChannel.callImageVisible(_textureInfo!.textureId).whenComplete(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void callImageInVisible() {
    if (_textureInfo?.textureId != null) {
      NImageChannel.callImageInVisible(_textureInfo!.textureId);
    }
  }
}
