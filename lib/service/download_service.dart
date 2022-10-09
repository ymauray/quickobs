import 'dart:async';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:quickobs/model/downloaded_file.dart';

class DownloadService extends StateNotifier<double> {
  DownloadService(
    StateController<String> statusLineNotifier,
    Directory cacheDirectory,
  )   : _statusLineNotifier = statusLineNotifier,
        _cacheDirectory = cacheDirectory,
        super(0);

  final StateController<String> _statusLineNotifier;
  final Directory _cacheDirectory;

  Future<File?> download(
    String assetUrl,
    Directory destinationDirectory,
  ) async {
    state = 0;

    final destFile = File(
      '${_cacheDirectory.path}/'
      '${assetUrl.substring(assetUrl.lastIndexOf('/') + 1)}',
    );

    if (destFile.existsSync()) return destFile;

    final control = await _downloadFile(
      'control file',
      '$assetUrl.sha256',
      File('${destFile.path}.sha256'),
    );

    final asset = await _downloadFile('tarball', assetUrl, destFile);

    final sha256 = control.file.readAsStringSync().split(' ')[0];
    if (asset.digest.toString() != sha256) {
      _statusLineNotifier.state = 'Downloaded file is corrupted';
      return null;
    }

    return asset.file;
  }

  Future<DownloadedFile> _downloadFile(
    String description,
    String url,
    File file,
  ) async {
    _statusLineNotifier.state = 'Starting download of $description';
    var downloaded = 0;
    final completer = Completer<DownloadedFile>();
    final request = Request('GET', Uri.parse(url));
    final streamResponse = await Client().send(request);
    final contentLength = streamResponse.contentLength!;

    final digestSink = AccumulatorSink<Digest>();
    final digestInput = sha256.startChunkedConversion(digestSink);

    streamResponse.stream.listen(
      (bytes) {
        // Update progress percentage
        downloaded += bytes.length;
        file.writeAsBytesSync(bytes, mode: FileMode.append, flush: true);
        digestInput.add(bytes);
        state = 100 * downloaded / contentLength;
        _statusLineNotifier.state =
            'Downloading : ${state.toStringAsFixed(2)}%';
      },
      onDone: () async {
        _statusLineNotifier.state = 'Download complete';
        digestInput.close();
        completer.complete(
          DownloadedFile(file: file, digest: digestSink.events.single),
        );
      },
      onError: (error) {
        _statusLineNotifier.state = 'Download failed : $error';
        debugPrint('Download failed: $error');
      },
      cancelOnError: true,
    );

    return completer.future;
  }
}
