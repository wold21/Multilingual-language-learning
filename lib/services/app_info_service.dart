import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  static final AppInfoService instance = AppInfoService._internal();
  AppInfoService._internal();

  Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  String get appName => 'Voca Storage';
}
