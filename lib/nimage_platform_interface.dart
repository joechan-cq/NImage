import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nimage_method_channel.dart';

abstract class NimagePlatform extends PlatformInterface {
  /// Constructs a NimagePlatform.
  NimagePlatform() : super(token: _token);

  static final Object _token = Object();

  static NimagePlatform _instance = MethodChannelNimage();

  /// The default instance of [NimagePlatform] to use.
  ///
  /// Defaults to [MethodChannelNimage].
  static NimagePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NimagePlatform] when
  /// they register themselves.
  static set instance(NimagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
