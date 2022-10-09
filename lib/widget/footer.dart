import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/provider/system_info_provider.dart';

class Footer extends ConsumerWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemInfo = ref.watch(systemInfoProvider);
    return Row(
      children: [
        ...systemInfo.when(
          data: (systemInfo) {
            final cacheSize =
                (systemInfo.cacheSize / 1024 / 1024).toStringAsFixed(2);
            return [
              Text(
                'System information : ${systemInfo.distro} '
                '${systemInfo.osVersion} (${systemInfo.codeName})',
              ),
              const Spacer(),
              Text('Cache size : $cacheSize MB'),
            ];
          },
          loading: () => const [Text('Loading')],
          error: (error, stackTrace) => [Text(error.toString())],
        ),
      ],
    );
  }
}
