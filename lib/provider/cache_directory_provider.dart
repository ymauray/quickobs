import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final cacheDirectoryProvider = Provider<Directory>((ref) {
  final home = Platform.environment['HOME']!;
  return Directory('$home/.cache/quickobs')..createSync(recursive: true);
});
