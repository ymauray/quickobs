import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/model/installed_version.dart';
import 'package:quickobs/provider/installed_versions_provider.dart';

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
          onSelected: (value) {
            switch (value) {
              case 1:
                Process.start(
                  '${_version.directory.path}/obs-portable',
                  [],
                  mode: ProcessStartMode.detached,
                );
                break;
              case 4:
                showDialog(
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
              child: Text('Upgrade'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 3,
              child: Text('Rename'),
            ),
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
