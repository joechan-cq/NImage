import 'nimage_platform_interface.dart';

class Nimage {
  Future<String?> getPlatformVersion() {
    return NimagePlatform.instance.getPlatformVersion();
  }
}
