import 'dart:convert';
import 'dart:io';

class InstalledVersion {
  InstalledVersion({
    required Directory directory,
    required String version,
    required String ubuntuVersion,
    required String release,
  })  : _directory = directory,
        _version = version,
        _ubuntuVersion = ubuntuVersion,
        _release = release;

  final Directory _directory;
  final String _version;
  final String _ubuntuVersion;
  final String _release;

  Directory get directory => _directory;
  String get version => _version;
  String get ubuntuVersion => _ubuntuVersion;
  String get release => _release;

  static Future<InstalledVersion?> fromDirectory(Directory directory) async {
    final files = directory.listSync();
    final manifest = files.where((file) => file.path.endsWith('manifest.txt'));
    if (manifest.isEmpty) {
      return null;
    }
    final manifestLine = await File(manifest.first.path)
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .first;

    final versionRegex = RegExp(
      r'Portable OBS Studio (.*) for Ubuntu (.*) manifest \(r(.*)\)$',
    );
    final versionFound = versionRegex.hasMatch(manifestLine);
    if (!versionFound) {
      return null;
    }
    final version = versionRegex.firstMatch(manifestLine)!.group(1)!;
    final ubuntuVersion = versionRegex.firstMatch(manifestLine)!.group(2)!;
    final release = versionRegex.firstMatch(manifestLine)!.group(3)!;

    return InstalledVersion(
      directory: directory,
      version: version,
      ubuntuVersion: ubuntuVersion,
      release: release,
    );
  }
}
