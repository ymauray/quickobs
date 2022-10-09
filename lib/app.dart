import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:quickobs/page/main_page.dart';
import 'package:quickobs/provider/system_info_provider.dart';
import 'package:yaru/yaru.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemInfo = ref.watch(systemInfoProvider);

    return YaruTheme(
      builder: (context, yaru, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            ...GlobalMaterialLocalizations.delegates,
            GlobalWidgetsLocalizations.delegate,
            FormBuilderLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              return systemInfo.when(
                data: (_) => const MainPage(),
                error: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        );
      },
    );
  }
}
