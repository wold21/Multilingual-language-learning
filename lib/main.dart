import 'package:eng_word_storage/services/database_service.dart';
import 'package:eng_word_storage/services/theme_service.dart';
import 'package:eng_word_storage/utils/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eng_word_storage/services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 초기화
  await Firebase.initializeApp();
  await DatabaseService.instance.initialize();
  await ThemeService.instance.initialize();
  await MobileAds.instance.initialize();
  await PurchaseService.instance.init();

  runApp(const MyApp());
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
          theme: ThemeData(
            useMaterial3: true,
            // 기본 색상
            primaryColor: const Color(0xFF3955D0),
            scaffoldBackgroundColor: Colors.grey[50],

            // AppBar 테마
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[50],
              foregroundColor: Colors.black87,
              elevation: 0,
            ),

            // 카드 테마
            cardTheme: CardTheme(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // 플로팅 버튼 테마
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF324BB9),
              foregroundColor: Colors.white,
            ),

            // 아이콘 테마
            iconTheme: const IconThemeData(
              color: Colors.black54,
            ),

            // 텍스트 테마
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: Colors.black87),
              bodyLarge: TextStyle(color: Colors.black87),
              bodyMedium: TextStyle(color: Colors.black54),
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            // 기본 색상
            primaryColor: const Color(0xFF3955D0),
            scaffoldBackgroundColor: const Color(0xFF121212),

            // AppBar 테마
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            // 카드 테마
            cardTheme: CardTheme(
              color: Colors.grey[850],
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // 플로팅 버튼 테마
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF324BB9),
              foregroundColor: Colors.white,
            ),

            // 아이콘 테마
            iconTheme: const IconThemeData(
              color: Colors.white70,
            ),

            // 텍스트 테마
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
