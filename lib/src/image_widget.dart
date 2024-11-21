import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class NImageChannel {
  static const channel = MethodChannel('nimage');

  static void disposeTexture(int textureId) {
    channel.invokeMethod('dispose', '$textureId').then((value) {
      if (NImage.debug) {
        print('release texture: $textureId');
      }
      return value;
    }).catchError((e) {
      print(e);
    });
  }
}

class NImage extends StatelessWidget {
  /// 是否DEBUG开启日志输出
  static bool debug = false;

  ///控件宽
  final double? width;

  ///控件高
  final double? height;

  ///占位Widget
  final Widget? placeHolder;

  ///加载出错后的Widget
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
