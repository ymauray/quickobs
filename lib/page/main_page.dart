import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickobs/provider/installed_versions_provider.dart';
import 'package:quickobs/widget/footer.dart';
import 'package:quickobs/widget/latest_release.dart';
import 'package:quickobs/widget/version_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedVersions = ref.watch(installedVersionProvider);

    final textController = TextEditingController();
    SharedPreferences.getInstance().then((prefs) {
      textController.text = prefs.getString('baseDirectory') ?? '';
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'quickobs',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LatestRelease(),
            const Divider(height: 32),
            Row(
              children: [
                const Text('Base directory\n(where OBSes are installed) :'),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: textController,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final selectedDirectory =
                        await FilePicker.platform.getDirectoryPath();
                    if (selectedDirectory != null) {
                      final sharedPrefs = await SharedPreferences.getInstance();
                      await sharedPrefs.setString(
                        'baseDirectory',
                        selectedDirectory,
                      );
                      textController.text = selectedDirectory;
                      ref.refresh(installedVersionProvider);
                    }
                  },
                  child: const Text('Browse'),
                ),
              ],
            ),
            const Divider(height: 32),
            installedVersions.when(
              data: (versions) {
                return Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Directory')),
                              DataColumn(label: Text('OBS Version')),
                              DataColumn(label: Text('Ubuntu version')),
                              DataColumn(label: Text('OBS Portable Release')),
                              DataColumn(label: Text('')),
                            ],
                            rows: versions
                                .map(
                                  (version) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          version.directory.path.substring(
                                            version.directory.path
                                                    .lastIndexOf('/') +
                                                1,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(version.version)),
                                      DataCell(Text(version.ubuntuVersion)),
                                      DataCell(Text('r${version.release}')),
                                      DataCell(
                                        VersionMenu(version: version),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Expanded(
                child: Center(
                  child: YaruCircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Expanded(
                child: Text(error.toString()),
              ),
            ),
            const Divider(height: 32),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
