import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/model/installed_version.dart';
import 'package:quickobs/provider/installed_versions_provider.dart';
import 'package:quickobs/widget/save_restore_dialog.dart';

class VersionMenu extends ConsumerWidget {
  const VersionMenu({
    required InstalledVersion version,
    super.key,
  }) : _version = version;

  final InstalledVersion _version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<int>(
          onSelected: (value) async {
            switch (value) {
              case 1:
                await Process.start(
                  '${_version.directory.path}/obs-portable',
                  [],
                  mode: ProcessStartMode.detached,
                );
                break;
              case 2:
                await showDialog<void>(
                  context: context,
                  builder: (context) => SaveRestoreDialog(_version, save: true),
                );
                break;
              case 3:
                await showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      SaveRestoreDialog(_version, save: false),
                );
                break;
              case 4:
                await showDialog<void>(
                  context: context,
                  builder: (context) {
                    final path = _version.directory.path.substring(
                      _version.directory.path.lastIndexOf('/') + 1,
                    );
                    return AlertDialog(
                      title: Text(
                        'Delete $path',
                      ),
                      content: Text(
                        'Are you sure you want to delete $path ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _version.directory.deleteSync(recursive: true);
                            ref.refresh(installedVersionProvider);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
                break;
              case 5:
                await Process.start(
                  'xdg-open',
                  [_version.directory.path],
                  mode: ProcessStartMode.detached,
                );
                break;
              default:
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 1,
              child: Text('Run'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 2,
              child: Text('Save config'),
            ),
            const PopupMenuItem(
              value: 3,
              child: Text('Restore config'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 5,
              child: Text('Open in file explorer'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 4,
              child: Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}
