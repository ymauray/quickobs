import 'package:flutter/widgets.dart';

@immutable
class Asset {
  const Asset({
    required String name,
    required String browserDownloadUrl,
  })  : _name = name,
        _browserDownloadUrl = browserDownloadUrl;

  final String _name;
  final String _browserDownloadUrl;

  String get name => _name;
  String get browserDownloadUrl => _browserDownloadUrl;
}
