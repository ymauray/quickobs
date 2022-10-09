import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/provider/cache_directory_provider.dart';
import 'package:quickobs/provider/installation_status_provider.dart';
import 'package:quickobs/service/download_service.dart';

final downloadServiceProvider =
    StateNotifierProvider<DownloadService, double>((ref) {
  return DownloadService(
    ref.read(installationStatusProvider.notifier),
    ref.read(cacheDirectoryProvider),
  );
});
