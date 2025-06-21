import 'package:bionic_news/services/read_article_service.dart';
import 'package:bionic_news/viewmodels/news_viewmodel.dart';
import 'package:bionic_news/widgets/bionic_reading_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// NewsTopicList와 SearchResultScreen에서 중복되는 UI 로직을 통합한 공통 위젯
class NewsListView extends StatefulWidget {
  const NewsListView({super.key});

  @override
  State<NewsListView> createState() => _NewsListViewState();
}

class _NewsListViewState extends State<NewsListView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final ReadArticleService _readArticleService = ReadArticleService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final viewModel = context.read<NewsViewModel>();
      if (viewModel.currentQuery != null) {
        viewModel.fetchNews(viewModel.currentQuery!);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<NewsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.state == NotifierState.loading &&
            viewModel.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.state == NotifierState.error &&
            viewModel.articles.isEmpty) {
          return Center(child: Text('오류가 발생했습니다: ${viewModel.errorMessage}'));
        }

        if (viewModel.articles.isEmpty &&
            viewModel.state == NotifierState.loaded) {
          return const Center(child: Text('뉴스가 없습니다.'));
        }

        return RefreshIndicator(
          onRefresh: () =>
              viewModel.fetchNews(viewModel.currentQuery!, isRefresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: viewModel.articles.length +
                (viewModel.state == NotifierState.loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == viewModel.articles.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final article = viewModel.articles[index];

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    article.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: article.isRead ? Colors.grey.shade600 : Colors.black87
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      article.formattedPubDate,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  onTap: () {
                    // 1. ViewModel의 상태를 즉시 업데이트하여 UI에 반영
                    viewModel.markArticleAsRead(article);
                    // 2. 읽은 기사 정보를 로컬 저장소에 영구 저장
                    _readArticleService.addReadArticle(article.content);

                    // ★★★ 여기가 수정된 부분입니다 ★★★
                    // 3. ReaderScreen으로 이동하는 대신, BionicReadingPopup을 띄웁니다.
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
    );
  }
}