import 'package:eng_word_storage/services/database_service.dart';
import 'package:flutter/material.dart';
import 'pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voca Storage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 기본 색상
        primaryColor: const Color(0xFF324BB9), // 파스텔 블루
        scaffoldBackgroundColor: Colors.grey[50],

        // AppBar 테마
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50], // scaffoldBackgroundColor와 동일하게 설정
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
      ),

      // 다크 모드 테마
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // 기본 색상
        primaryColor: const Color(0xFF324BB9), // 다크모드용 파스텔 블루
        scaffoldBackgroundColor: const Color(0xFF121212),

        // AppBar 테마
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color(0xFF121212), // scaffoldBackgroundColor와 동일하게 설정
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
      ),

      // 시스템 설정에 따라 라이트/다크 모드 자동 전환
      themeMode: ThemeMode.dark,
      home: const MainPage(),
    );
  }
}
