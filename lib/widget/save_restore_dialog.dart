import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/model/installed_version.dart';

class SaveRestoreDialog extends ConsumerWidget {
  const SaveRestoreDialog(
    InstalledVersion version, {
    required bool save,
    super.key,
  })  : _version = version,
        _save = save;

  final InstalledVersion _version;
  final bool _save;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormBuilderState>();
    final controller = TextEditingController();

    return AlertDialog(
      title: Text(_save ? 'Save config' : 'Restore config'),
      content: SizedBox(
        width: 700,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilder(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_save)
                      const Text(
                          'Pick a folder to save your config to.\nThe "config" '
                          'folder of the selected installation will be copied '
                          'there.'),
                    if (!_save)
                      const Text(
                          'Pick a folder to restore your config from.\nIt must '
                          'contain a "config" subfolder that will replace the '
                          '"config" folder of the selected installation.'),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            controller: controller,
                            enabled: false,
                            name: 'path',
                            decoration: InputDecoration(
                              labelText:
                                  'Folder to ${_save ? 'save' : 'restore'} '
                                  'your config ${_save ? 'to' : 'from'}',
                            ),
                            onChanged: (val) {},
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FilePicker.platform
                                .getDirectoryPath()
                                .then((selectedDirectory) {
                              if (selectedDirectory != null) {
                                controller.text = selectedDirectory;
                              }
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text('Browse'),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: () {
            formKey.currentState!.save();
            if ((formKey.currentState!.value['path'] == null) ||
                (formKey.currentState!.value['path'] == '')) {
              return;
            }
            if (!_save &&
                !Directory('${formKey.currentState!.value['path']}/config')
                    .existsSync()) {
              return;
            }
            if (_save) {
              Process.runSync(
                'rm',
                ['-rf', '${formKey.currentState!.value['path']}/config'],
              );
              Process.runSync('cp', [
                '-a',
                '${_version.directory.path}/config',
                '${formKey.currentState!.value['path']}',
              ]);
            } else {
              Process.runSync('rm', [
                '-rf',
                '${_version.directory.path}/config',
              ]);
              Process.runSync('cp', [
                '-a',
                '${formKey.currentState!.value['path']}/config',
                _version.directory.path,
              ]);
            }
            Navigator.of(context).pop();
          },
          child: Text(_save ? 'Save' : 'Restore'),
        ),
      ],
    );
  }
}
