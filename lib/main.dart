import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/news_feed_screen.dart';
import 'viewmodels/news_viewmodel.dart';

Future<void> main() async {
  // runApp을 실행하기 전에 Flutter 엔진과의 바인딩을 초기화합니다.
  // main 함수에서 비동기 작업을 수행할 때 반드시 필요합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일을 로드하고, 로드가 끝날 때까지 기다립니다.
  await dotenv.load(fileName: ".env");

  // 환경 변수 로드가 완료된 후 앱을 실행합니다.
  runApp(
    ChangeNotifierProvider(
      create: (context) => NewsViewModel(),
      child: const MyApp(),
    ),
  );
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