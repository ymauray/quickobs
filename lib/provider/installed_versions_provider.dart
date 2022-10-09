import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/constants.dart';
import 'package:quickobs/model/installed_version.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<InstalledVersion>> _loadInstallations(Directory directory) async {
  if (!directory.existsSync()) {
    return [];
  }
  final files = directory.listSync(followLinks: false).toList();
  final versions = <InstalledVersion>[];
  for (final file in files) {
    if (file is Directory) {
      final version = await InstalledVersion.fromDirectory(file);
      if (version != null) {
        versions.add(version);
      }
    }
  }
  versions.sort((a, b) => a.directory.path.compareTo(b.directory.path));
  return versions;
}

final installedVersionProvider = FutureProvider<List<InstalledVersion>>(
  (ref) async {
    final prefs = await SharedPreferences.getInstance();
    final baseDirectory = prefs.getString(kBaseDirectory);
    if (baseDirectory == null) {
      return [];
    }
    final directory = Directory(baseDirectory);
    return compute(_loadInstallations, directory);
  },
);
