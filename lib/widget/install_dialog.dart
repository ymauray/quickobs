import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/constants.dart';
import 'package:quickobs/model/system_info.dart';
import 'package:quickobs/provider/download_service_provider.dart';
import 'package:quickobs/provider/installation_status_provider.dart';
import 'package:quickobs/provider/installed_versions_provider.dart';
import 'package:quickobs/widget/installation_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallDialog extends ConsumerWidget {
  const InstallDialog(SystemInfo data, {super.key}) : _data = data;

  final SystemInfo _data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormBuilderState>();

    return AlertDialog(
      title: Text('Install ${_data.latestRelease.name}'),
      content: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilder(
                  key: formKey,
                  initialValue: const {
                    'path': '',
                  },
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        autovalidateMode: AutovalidateMode.always,
                        name: 'path',
                        decoration: const InputDecoration(
                          labelText: 'Path (below base directory)',
                        ),
                        onChanged: (val) {},
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      FormBuilderDropdown<String>(
                        // autovalidate: true,
                        name: 'asset',
                        decoration: const InputDecoration(
                          labelText: 'Asset',
                        ),
                        items: _data.latestRelease.assets
                            .where(
                              (asset) =>
                                  asset.name.contains(_data.osVersion) &&
                                  asset.name.endsWith('.tar.bz2'),
                            )
                            .map(
                              (asset) => DropdownMenuItem(
                                value: asset.name,
                                child: Text(asset.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {},
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                const InstallationStatus(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: () => _install(context, formKey, ref),
          child: const Text('Install'),
        ),
      ],
    );
  }

  Future<void> _install(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
    WidgetRef ref,
  ) async {
    formKey.currentState!.save();
    if ((formKey.currentState!.value['path'] == null) ||
        (formKey.currentState!.value['path'] == '')) {
      ref.read(installationStatusProvider.notifier).state = 'Path is required';
      return;
    }
    if ((formKey.currentState!.value['asset'] == null) ||
        (formKey.currentState!.value['asset'] == null)) {
      ref.read(installationStatusProvider.notifier).state = 'Asset is required';
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final baseDirectoryPath = prefs.getString(kBaseDirectory);
    if (baseDirectoryPath == null) {
      ref.read(installationStatusProvider.notifier).state =
          "Base directory is not set. This shouldn't have happened...";
      return;
    }
    final baseDirectory = Directory(baseDirectoryPath);
    if (!baseDirectory.existsSync()) {
      ref.read(installationStatusProvider.notifier).state =
          'Base directory does not exist. '
          "This shouldn't have happened...";
      return;
    }
    final path = formKey.currentState!.value['path'] as String;
    final newDirectory = Directory('$baseDirectoryPath/$path');
    if (newDirectory.existsSync()) {
      ref.read(installationStatusProvider.notifier).state =
          'Path already exist. ';
      return;
    }
    try {
      await newDirectory.create();
    } catch (e) {
      /* nothing to do here, we'll deal with the error below */
    }
    if (!newDirectory.existsSync()) {
      ref.read(installationStatusProvider.notifier).state =
          'Cannot create path. ';
      return;
    }

    /* For now, we remove the directory, just in case something goes wrong
     * during the download. */
    newDirectory.deleteSync(recursive: true);

    final asset = await ref.read(downloadServiceProvider.notifier).download(
          _data.latestRelease.assets
              .firstWhere(
                (asset) => asset.name == formKey.currentState!.value['asset'],
              )
              .browserDownloadUrl,
          newDirectory,
        );

    if (asset != null) {
      ref.read(installationStatusProvider.notifier).state =
          'Extracting archive...';
      final tempDir = Directory('${newDirectory.parent.path}/_temp')
        ..createSync();
      await Process.run('tar', ['-C', tempDir.path, '-xf', asset.path]);
      await Directory(
        '${tempDir.path}'
        "${asset.path.substring(
              asset.path.lastIndexOf('/'),
            ).replaceAll(
              '.tar.bz2',
              '',
            )}",
      ).rename(newDirectory.path);
      ref.refresh(installedVersionProvider);
      Navigator.of(context).pop();
    }
  }
}
