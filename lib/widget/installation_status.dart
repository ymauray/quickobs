import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/provider/installation_status_provider.dart';

class InstallationStatus extends ConsumerWidget {
  const InstallationStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installationStatus = ref.watch(installationStatusProvider);

    return Text(installationStatus);
  }
}
