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
                  'QuickOBS',
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
                              DataColumn(
                                label: Text('OBS Studio Portable Release'),
                              ),
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
            FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.getBool('hideInfo') == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(
                          height: 32,
                        ),
                        ColoredBox(
                          color: Theme.of(context).colorScheme.primary,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                Text(
                                  'Note : the first time you install OBS '
                                  'Studio Portable, you need to run the '
                                  '"obs-dependencies" script to install the '
                                  'required dependencies. This only needs to '
                                  'be done once.',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        SharedPreferences.getInstance()
                                            .then((pref) {
                                          pref.setBool('hideInfo', true);
                                          ref.refresh(installedVersionProvider);
                                        });
                                      },
                                      child: Text(
                                        'Dismiss',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              },
            ),
            const Divider(height: 32),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
