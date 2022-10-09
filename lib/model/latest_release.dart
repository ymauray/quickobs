import 'package:flutter/widgets.dart';
import 'package:quickobs/model/asset.dart';

@immutable
class LatestRelease {
  const LatestRelease({
    required String name,
    required List<Asset> assets,
  })  : _name = name,
        _assets = assets;

  final String _name;
  final List<Asset> _assets;

  String get name => _name;
  List<Asset> get assets => _assets;
}
