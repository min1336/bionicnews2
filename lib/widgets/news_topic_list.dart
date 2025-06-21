import 'package:bionic_news/viewmodels/news_viewmodel.dart';
import 'package:bionic_news/widgets/news_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsTopicList extends StatelessWidget {
  final String query;
  const NewsTopicList({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // 각 탭에 대해 NewsViewModel을 생성하고 초기 데이터를 로드합니다.
    return ChangeNotifierProvider(
      create: (_) => NewsViewModel()..fetchNews(query, isRefresh: true),
      // 공통 위젯인 NewsListView를 사용하여 UI를 그립니다.
      child: const NewsListView(),
    );
  }
}