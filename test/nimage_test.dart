import 'package:flutter_test/flutter_test.dart';
import 'package:nimage/nimage.dart';
import 'package:nimage/nimage_platform_interface.dart';
import 'package:nimage/nimage_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNimagePlatform
    with MockPlatformInterfaceMixin
    implements NimagePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NimagePlatform initialPlatform = NimagePlatform.instance;

  test('$MethodChannelNimage is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNimage>());
  });

  test('getPlatformVersion', () async {
    Nimage nimagePlugin = Nimage();
    MockNimagePlatform fakePlatform = MockNimagePlatform();
    NimagePlatform.instance = fakePlatform;

    expect(await nimagePlugin.getPlatformVersion(), '42');
  });
}
