import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'nimage_platform_interface.dart';

/// An implementation of [NimagePlatform] that uses method channels.
class MethodChannelNimage extends NimagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nimage');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
