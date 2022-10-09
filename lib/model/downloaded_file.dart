import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';

@immutable
class DownloadedFile {
  const DownloadedFile({
    required File file,
    required Digest digest,
  })  : _file = file,
        _digest = digest;

  final File _file;
  final Digest _digest;

  File get file => _file;
  Digest get digest => _digest;
}
