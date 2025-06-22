import 'package:focus_news/services/ad_service.dart';
import 'package:focus_news/services/iap_service.dart';
import 'package:focus_news/viewmodels/bookmark_viewmodel.dart';
import 'package:focus_news/viewmodels/settings_viewmodel.dart';
import 'package:focus_news/viewmodels/topic_viewmodel.dart';
import 'package:focus_news/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:focus_news/screens/news_feed_screen.dart';

final AdService adService = AdService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  IapService().initialize();

  adService.createAndLoadInterstitialAd();

  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => BookmarkViewModel()),
        ChangeNotifierProvider(create: (_) => TopicViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
      ],
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
          title: 'Focus News',
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