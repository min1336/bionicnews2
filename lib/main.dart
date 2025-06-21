import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/news_feed_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // ★★★ FIXED: Removed the MultiProvider wrapper that was causing the crash ★★★
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bionic News App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      home: const NewsFeedScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}