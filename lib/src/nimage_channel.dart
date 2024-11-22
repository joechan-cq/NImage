import 'package:flutter/services.dart';
import 'package:nimage/src/nimage_widget.dart';

///
/// Channel Object that communicates with Native
///
class NImageChannel {
  static const String _mthCreateTexture = 'mth_createTexture';
  static const String _mthLoadImage = 'mth_loadImage';
  static const String _mthDestroyTexture = 'mth_destroyTexture';
  static const String _mthCallImageVisible = 'mth_setVisible';
  static const String _mthCallImageInVisible = 'mth_setInvisible';

  static const channel = MethodChannel('nimage');

  ///create native Texture.
  static Future<int?> createTexture() {
    return channel.invokeMethod<int>(_mthCreateTexture);
  }

  ///notify native that texture will be visible.
  ///
  ///it's used for calling native to resume gif or webp animation.
  static Future<void> callImageVisible(int textureId) {
    return channel.invokeMethod(_mthCallImageVisible, textureId);
  }

  ///notify native that texture will be invisible.
  ///
  ///it's used for calling native to pause/stop gif or webp animation.
  static Future<void> callImageInVisible(int textureId) {
    return channel.invokeMethod(_mthCallImageInVisible, textureId);
  }

  static void destroyTexture(int textureId) {
    channel.invokeMethod(_mthDestroyTexture, textureId).then((value) {
      if (NImage.debug) {
        print('release texture: $textureId');
      }
      return value;
    }).catchError((e) {
      print(e);
    });
  }
}
