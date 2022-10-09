import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:quickobs/model/asset.dart';
import 'package:quickobs/model/latest_release.dart';
import 'package:quickobs/model/system_info.dart';
import 'package:quickobs/provider/cache_directory_provider.dart';

LatestRelease _parseLatestRelease(String responseBody) {
  final parsed = jsonDecode(responseBody) as Map<String, dynamic>;
  final name = parsed['name'] as String? ?? '';
  final assetsMap =
      List<Map<String, dynamic>>.from(parsed['assets'] as List<dynamic>);
  final assets = assetsMap
      .map(
        (assetMap) => Asset(
          name: assetMap['name'] as String? ?? '',
          browserDownloadUrl: assetMap['browser_download_url'] as String? ?? '',
        ),
      )
      .toList();

  return LatestRelease(name: name, assets: assets);
}

final systemInfoProvider = FutureProvider((ref) async {
  final result = await Process.run('lsb_release', ['-is', '-rs', '-cs']);
  final lines = (result.stdout as String).trim().split('\n');

  final distro = lines[0].toLowerCase();
  final osVersion = lines[1].toLowerCase();
  final codeName = lines[2].toLowerCase();

  final response = await http.Client().get(
    Uri.parse('https://api.github.com/repos/wimpysworld'
        '/obs-studio-portable/releases/latest'),
  );

  final latestRelease = await compute(_parseLatestRelease, response.body);
  final cacheDirectory = ref.read(cacheDirectoryProvider);
  final cacheSize = cacheDirectory.listSync().fold(0, (previousValue, element) {
    if (element.statSync().type == FileSystemEntityType.file) {
      return previousValue + element.statSync().size;
    } else {
      return previousValue;
    }
  });

  return SystemInfo(
    distro: distro,
    osVersion: osVersion,
    codeName: codeName,
    latestRelease: latestRelease,
    cacheSize: cacheSize,
  );
});
