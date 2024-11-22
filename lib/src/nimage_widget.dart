import 'package:flutter/widgets.dart';
import 'package:nimage/src/cache/texture_cache_mgr.dart';
import 'package:nimage/src/models.dart';
import 'package:nimage/src/nimage_channel.dart';

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
    }
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
