import 'package:bionic_news/models/news_article.dart';
import 'package:bionic_news/viewmodels/news_viewmodel.dart';
import 'package:bionic_news/widgets/bionic_reading_popup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatelessWidget {
  final String query;
  const SearchResultScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // 처음 진입 시 isRefresh: true를 명시적으로 호출하여 데이터를 불러옵니다.
      create: (_) => NewsViewModel()..fetchNews(query, isRefresh: true),
      child: _SearchResultView(query: query),
    );
  }
}

class _SearchResultView extends StatefulWidget {
  final String query;
  const _SearchResultView({required this.query});

  @override
  State<_SearchResultView> createState() => __SearchResultViewState();
}

class __SearchResultViewState extends State<_SearchResultView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // initState 시점에는 context를 통한 상위 위젯 접근이 불안정할 수 있으므로,
    // 리스너 콜백 안에서 context.read를 사용하는 것이 더 안전합니다.
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // 위젯이 여전히 마운트 상태일 때만 로직을 실행합니다.
    if (!mounted) return;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      // context.read는 리스너 콜백처럼 일회성 이벤트에서 사용하기에 적합합니다.
      final viewModel = context.read<NewsViewModel>();
      // isRefresh를 false(기본값)로 호출하여 '더 불러오기'를 트리거합니다.
      viewModel.fetchNews(viewModel.currentQuery!);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("'${widget.query}' 검색 결과"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Consumer<NewsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == NotifierState.loading && viewModel.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.state == NotifierState.error && viewModel.articles.isEmpty) {
            return Center(child: Text('오류가 발생했습니다: ${viewModel.errorMessage}'));
          }

          if (viewModel.articles.isEmpty && viewModel.state == NotifierState.loaded) {
            return const Center(child: Text('검색된 뉴스가 없습니다.'));
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchNews(widget.query, isRefresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: viewModel.articles.length + (viewModel.state == NotifierState.loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == viewModel.articles.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final article = viewModel.articles[index];
                String formattedDate = '';
                try {
                  final DateTime parsedDate = DateFormat("E, d MMM yyyy HH:mm:ss Z", "en_US").parse(article.pubDate);
                  formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(parsedDate);
                } catch (e) {
                  formattedDate = article.pubDate;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    title: Text(
                      article.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return BionicReadingPopup(article: article);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}