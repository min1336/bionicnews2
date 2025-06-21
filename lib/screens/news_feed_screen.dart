import 'package:bionic_news/delegates/news_search_delegate.dart';
import 'package:bionic_news/screens/search_result_screen.dart';
import 'package:bionic_news/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/news_topic_list.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final List<String> _topics = ['IT/과학', '경제', '생활/문화', '정치', '세계', '스포츠'];

  Future<void> _onSearchPressed() async {
    final String? result = await showSearch<String>(
      context: context,
      delegate: NewsSearchDelegate(),
    );

    if (result != null && result.isNotEmpty && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(query: result),
        ),
      );
    }
  }

  // ★★★ 여기가 추가된 부분입니다 ★★★
  void _onSettingsPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _topics.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bionic Reading 뉴스피드'),
          actions: [
            IconButton(
              onPressed: _onSearchPressed,
              icon: const Icon(Icons.search),
              tooltip: '뉴스 검색',
            ),
            // ★★★ 여기가 추가된 부분입니다 ★★★
            IconButton(
              onPressed: _onSettingsPressed,
              icon: const Icon(Icons.settings),
              tooltip: '설정',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: _topics.map((String topic) => Tab(text: topic)).toList(),
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 15),
            tabAlignment: TabAlignment.start,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            indicatorWeight: 3,
          ),
        ),
        body: TabBarView(
          children: _topics.map((String topic) {
            return NewsTopicList(query: topic);
          }).toList(),
        ),
      ),
    );
  }
}