import 'dart:async';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionCheckService {
  final remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.setDefaults(const {
      "last_version": "1.0.0",
      "force_update": false,
      "grace_period_end": "2024-05-01T00:00:00Z",
    });

    await remoteConfig.fetchAndActivate();
  }

  List<int> _parseVersion(String version) {
    return version.split('.').map((e) => int.parse(e)).toList();
  }

  int _compareVersions(List<int> current, List<int> other) {
    for (var i = 0; i < current.length; i++) {
      if (current[i] < other[i]) return -1;
      if (current[i] > other[i]) return 1;
    }
    return 0;
  }

  Future<bool> checkForUpdate(BuildContext context) async {
    try {
      return await _needsUpdate();
    } catch (e) {
      debugPrint('업데이트 체크 오류: $e');
      return false;
    }
  }

  Future<bool> _needsUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final latestVersion = remoteConfig.getString('last_version');
      final forceUpdate = remoteConfig.getBool('force_update');
      final gracePeriodEndStr = remoteConfig.getString('grace_period_end');

      DateTime? gracePeriodEnd;
      if (gracePeriodEndStr.isNotEmpty) {
        gracePeriodEnd = DateTime.tryParse(gracePeriodEndStr);
      }

      final current = _parseVersion(currentVersion);
      final latest = _parseVersion(latestVersion);

      final now = DateTime.now().toUtc();
      final isPastGracePeriod =
          gracePeriodEnd != null && now.isAfter(gracePeriodEnd);

      if (_compareVersions(current, latest) < 0) {
        return forceUpdate && isPastGracePeriod;
      }

      return false;
    } catch (e) {
      debugPrint('버전 체크 오류: $e');
      return false;
    }
  }

  Future<bool> launchStore(BuildContext context, bool forceUpdate) async {
    const packageName = 'com.seohae.laboca';
    const androidUrl = 'market://details?id=$packageName';
    const webUrl = 'https://play.google.com/store/apps/details?id=$packageName';
    const iosUrl = 'https://apps.apple.com/app/idYOUR_APP_ID';

    Uri uri;
    if (Platform.isAndroid) {
      uri = Uri.parse(androidUrl);
    } else {
      uri = Uri.parse(iosUrl);
    }

    try {
      if (await _tryLaunchUrl(uri, forceUpdate, context)) {
        return true;
      } else {
        Uri fallbackUri =
            Platform.isAndroid ? Uri.parse(webUrl) : Uri.parse(iosUrl);
        if (await _tryLaunchUrl(fallbackUri, forceUpdate, context)) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> _tryLaunchUrl(
      Uri uri, bool forceUpdate, BuildContext context) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (forceUpdate) {
        exit(0);
      } else {
        Navigator.pop(context);
      }
      return true;
    }
    return false;
  }
}
