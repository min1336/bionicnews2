import 'package:bionic_news/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/news_feed_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Bionic News App',
          // ★★★ 여기가 수정된 부분입니다 ★★★
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.themeColor,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.grey[100],
            cardTheme: CardTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.themeColor,
              brightness: Brightness.dark,
            ),
            cardTheme: CardTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          themeMode: settings.themeMode,
          home: const NewsFeedScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}