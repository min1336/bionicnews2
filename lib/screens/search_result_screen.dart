import 'package:bionic_news/viewmodels/news_viewmodel.dart';
import 'package:bionic_news/widgets/news_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatelessWidget {
  final String query;
  const SearchResultScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // 검색 결과 화면에 진입 시 NewsViewModel을 생성하고 데이터를 로드합니다.
    return ChangeNotifierProvider(
      create: (_) => NewsViewModel()..fetchNews(query, isRefresh: true),
      // Consumer를 사용하여 AppBar 제목에 현재 쿼리를 표시할 수 있도록 합니다.
      child: Consumer<NewsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("'${viewModel.currentQuery ?? query}' 검색 결과"),
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
            ),
            // Scaffold의 body에 공통 위젯인 NewsListView를 배치합니다.
            body: const NewsListView(),
          );
        },
      ),
    );
  }
}