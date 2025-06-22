import 'package:focus_news/viewmodels/news_viewmodel.dart';
import 'package:focus_news/widgets/error_display_widget.dart';
import 'package:focus_news/widgets/news_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatelessWidget {
  final String query;
  const SearchResultScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsViewModel()..fetchNews(query, isRefresh: true),
      child: Consumer<NewsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("'${viewModel.currentQuery ?? query}' 검색 결과"),
            ),
            body: Builder(builder: (context) {
              if (viewModel.state == NotifierState.error &&
                  viewModel.articles.isEmpty) {
                return ErrorDisplayWidget(
                  errorMessage: viewModel.errorMessage,
                  onRetry: () {
                    viewModel.fetchNews(query, isRefresh: true);
                  },
                );
              }
              return const NewsListView();
            }),
          );
        },
      ),
    );
  }
}