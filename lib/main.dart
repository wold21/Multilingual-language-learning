import 'package:flutter/material.dart';
import 'package:eng_word_storage/themes.dart';
import 'package:eng_word_storage/services/database_service.dart';
import 'package:eng_word_storage/services/theme_service.dart';
import 'package:eng_word_storage/utils/splash_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eng_word_storage/services/purchase_service.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await DatabaseService.instance.initialize();
  await ThemeService.instance.initialize();
  await MobileAds.instance.initialize();
  await PurchaseService.instance.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('ko'),
        Locale('fil'),
        Locale('ms'),
        Locale('hi'),
        Locale('ja'),
        Locale('my'),
        // Locale('ru'),
        Locale('th'),
        Locale('zh'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeService.instance.themeMode,
      builder: (context, ThemeMode themeMode, child) {
        return MaterialApp(
          title: 'Voca Storage',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          home: const SplashScreen(),
        );
      },
    );
  }
}
