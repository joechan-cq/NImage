import 'dart:math';
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

int _requestNum = 0;

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
      return NImageTexture(
        uri: src!,
        width: width,
        height: height,
      );
    });
  }
}

class NImageTexture extends StatefulWidget {
  final String uri;
  final double? width;
  final double? height;

  final Widget? placeHolder;
  final ImageErrorWidgetBuilder? errorBuilder;

  const NImageTexture({
    super.key,
    required this.uri,
    this.width,
    this.height,
    this.placeHolder,
    this.errorBuilder,
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

  /// current image texture bound with State
  TextureInfo? _textureInfo;

  late int _num;

  @override
  void initState() {
    super.initState();
    _uri = widget.uri;
    _textureWidth = widget.width ?? 0;
    _textureHeight = widget.height ?? 0;
    _loading = true;
    _error = false;
    _load(true);
  }

  @override
  void didUpdateWidget(covariant NImageTexture oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool reload = false;
    if (_uri != widget.uri || _error) {
      // if image uri changed or has error when loaded.
      _uri = widget.uri;
      reload = true;
    } else {
      //size changed
      if (widget.width != oldWidget.width ||
          widget.height != oldWidget.height) {
        _textureWidth = widget.width ?? 0;
        _textureHeight = widget.height ?? 0;
        reload = true;
      }
    }

    if (reload) {
      //decrease the current reference
      if (_textureInfo != null) {
        int count = ImageTextureCache.instance.getRefCount(_textureInfo!);
        if (count == 1) {
          callImageInVisible();
        }
        ImageTextureCache.instance.decreaseRef(_textureInfo!);
        if (NImage.debug) {
          print(
              'decreaseRef for reload [${_textureInfo!.textureId}, ${_textureInfo!.key}], ref-count: ${max(0, count - 1)}');
        }
      }
      _load(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposeTextureInfo();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, cs) {
      double w;
      double h;
      if (widget.width == null) {
        w = cs.maxWidth;
      } else {
        w = cs.constrainWidth(widget.width!);
      }
      if (widget.height == null) {
        h = cs.maxHeight;
      } else {
        h = cs.constrainHeight(widget.height!);
      }
      if (_loading) {
        return SizedBox(width: w, height: h, child: widget.placeHolder);
      }
      if (_error || _textureInfo == null) {
        if (widget.errorBuilder != null) {
          return SizedBox(
              width: w,
              height: h,
              child: widget.errorBuilder!(context, 'load src is null', null));
        } else {
          return SizedBox(width: w, height: h);
        }
      }
      Widget t = Texture(textureId: _textureInfo!.textureId);
      return SizedBox(width: w, height: h, child: t);
    });
  }

  void _load(bool init) {
    //try to find the cached texture.
    _textureInfo = ImageTextureCache.instance.getImageTexture(TextureInfo.fake(
      uri: _uri,
      width: _textureWidth,
      height: _textureHeight,
    ).key);
    if (_textureInfo != null) {
      _showExistedTexture();
    } else {
      //load by native
      if (!init) {
        setState(() {
          _loading = true;
          _error = false;
        });
      }
      //create texture first.
      LoadWorker w = LoadWorker();
      _createTexture(w).then((worker) async {
        assert(worker.textureId != null);
        if (!mounted) {
          //the case occurs when listview scroll quickly.
          NImageChannel.destroyTexture(worker.textureId!);
          if (NImage.debug) {
            print('destroyTexture [${worker.textureId}] because of unmounted');
          }
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
          if (!mounted) {
            NImageChannel.destroyTexture(worker.textureId!);
            if (NImage.debug) {
              print(
                  'destroyTexture [${worker.textureId}] because of unmounted');
            }
          } else {
            int tid = worker.textureId!;
            NImageInfo? imageInfo = worker.imageInfo;
            if (imageInfo != null) {
              TextureInfo textureInfo = TextureInfo(
                uri: _uri,
                width: _textureWidth,
                height: _textureHeight,
                textureId: tid,
                imageKey: imageInfo.imageKey,
                imageInfo: imageInfo,
              );
              worker.textureInfo = textureInfo;
              // put the texture to cache
              _saveTextureInfo(worker);
              setState(() {
                _loading = false;
                _error = false;
              });
            } else {
              setState(() {
                _loading = false;
                _error = true;
              });
            }
          }
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = true;
          });
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
    _num = _requestNum++;
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
      //just add the texture into LruCache.
      ImageTextureCache.instance.addTextureInfo2LruCache(
          worker.textureInfo!.key, worker.textureInfo!);
    } else {
      //the request matches the state
      _textureInfo = worker.textureInfo;
      int refCount =
          ImageTextureCache.instance.increaseRef(worker.textureInfo!);
      if (NImage.debug) {
        print(
            'loaded from native [${_textureInfo!.textureId}, ${_textureInfo!.key}], now ref-count: $refCount');
      }
    }
  }

  String _loadRequestKey() {
    return '$_uri-$_textureWidth-$_textureHeight-$_num';
  }

  void _showExistedTexture() {
    _loading = false;
    _error = false;
    int refCount = ImageTextureCache.instance.increaseRef(_textureInfo!);
    if (NImage.debug) {
      print(
          'find existed texture [${_textureInfo!.textureId}, ${_textureInfo!.key}], now ref-count: $refCount');
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

  void _disposeTextureInfo() {
    if (_textureInfo == null) {
      if (NImage.debug) {
        print('dispose, but textureInfo is null');
      }
      return;
    }
    int count = ImageTextureCache.instance.getRefCount(_textureInfo!);
    if (count == 1) {
      //this is the last reference.
      //so call invisible to stop the gif/webp.
      callImageInVisible();
    }
    if (NImage.debug) {
      print(
          'decreaseRef when disposed [${_textureInfo!.textureId}, ${_textureInfo!.key}], now ref-count: ${max(0, count - 1)}');
    }
    ImageTextureCache.instance.decreaseRef(_textureInfo!);
  }
}
