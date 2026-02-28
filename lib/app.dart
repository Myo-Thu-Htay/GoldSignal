import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_signal/dashboard/provider/setting_provider.dart';
import 'core/routing/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingAsync = ref.watch(settingsProvider);

    return settingAsync.when(
      data: (setting) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          themeMode: setting.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          locale: Locale(setting.languageCode),
          supportedLocales: const [
            Locale('en'),
            Locale('my'),
          ],
          localizationsDelegates: const [
            // AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerDelegate: AppRouter.delegate,
          routeInformationParser: AppRouter.parser,
        );
      },
      error: (error, stackTrace) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Text('Error loading settings'),
            ),
          ),
        );
      },
      loading: () {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
