import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/provider/installation_status_provider.dart';
import 'package:quickobs/provider/system_info_provider.dart';
import 'package:quickobs/widget/install_dialog.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LatestRelease extends ConsumerWidget {
  const LatestRelease({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemInfo = ref.watch(systemInfoProvider);

    return Row(
      children: [
        const Text('OBS Studio Portable latest release :'),
        const SizedBox(width: 16),
        ...systemInfo.when(
          data: (data) => [
            Text(data.latestRelease.name),
            const Spacer(),
            TextButton(
              child: const Text('Install'),
              onPressed: () {
                ref.read(installationStatusProvider.notifier).state = 'Ready';
                showDialog<void>(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => InstallDialog(data),
                );
              },
            ),
          ],
          loading: () => [
            const SizedBox(
              height: 16,
              child: YaruCircularProgressIndicator(),
            )
          ],
          error: (error, stack) => [Text(error.toString())],
        ),
      ],
    );
  }
}
