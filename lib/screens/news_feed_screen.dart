import 'package:focus_news/delegates/news_search_delegate.dart';
import 'package:focus_news/screens/bookmark_screen.dart';
import 'package:focus_news/screens/edit_topics_screen.dart';
import 'package:focus_news/screens/search_result_screen.dart';
import 'package:focus_news/screens/settings_screen.dart';
import 'package:focus_news/viewmodels/topic_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/news_topic_list.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
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

  void _onSettingsPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _onBookmarksPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BookmarkScreen(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, List<String> topics) {
    return AppBar(
      // ★★★ 여기가 수정된 부분입니다: 앱 이름 변경 ★★★
      title: const Text('Focus News'),
      actions: [
        IconButton(
          onPressed: _onBookmarksPressed,
          icon: const Icon(Icons.collections_bookmark_outlined),
          tooltip: '북마크',
        ),
        IconButton(
          onPressed: _onSearchPressed,
          icon: const Icon(Icons.search),
          tooltip: '뉴스 검색',
        ),
        IconButton(
          onPressed: _onSettingsPressed,
          icon: const Icon(Icons.settings_outlined),
          tooltip: '설정',
        ),
      ],
      bottom: topics.isNotEmpty
          ? TabBar(
        isScrollable: true,
        tabs: topics.map((String topic) => Tab(text: topic)).toList(),
        labelStyle:
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 15),
        tabAlignment: TabAlignment.start,
        indicatorColor: Theme.of(context).colorScheme.secondary,
        indicatorWeight: 3,
      )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TopicViewModel>(
      builder: (context, topicViewModel, child) {
        final userTopics = topicViewModel.userTopics;

        if (userTopics.isEmpty) {
          return Scaffold(
            appBar: _buildAppBar(context, []),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '표시할 관심 주제가 없습니다.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('관심 주제 편집하기'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const EditTopicsScreen(),
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: userTopics.length,
          child: Scaffold(
            appBar: _buildAppBar(context, userTopics),
            body: TabBarView(
              children: userTopics.map((String topic) {
                return NewsTopicList(
                  key: ValueKey(topic),
                  query: topic,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}