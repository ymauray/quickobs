import 'package:flutter/widgets.dart';
import 'package:quickobs/model/latest_release.dart';

@immutable
class SystemInfo {
  const SystemInfo({
    required this.distro,
    required this.osVersion,
    required this.codeName,
    required this.latestRelease,
    required this.cacheSize,
  });

  final String distro;
  final String osVersion;
  final String codeName;
  final LatestRelease latestRelease;
  final int cacheSize;
}
