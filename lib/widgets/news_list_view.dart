import 'package:focus_news/services/read_article_service.dart';
import 'package:focus_news/viewmodels/news_viewmodel.dart';
import 'package:focus_news/widgets/news_card_skeleton.dart';
import 'package:focus_news/widgets/reader_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        // ★★★ 여기가 수정된 부분입니다 ★★★
        // 최초 로딩 시, 스켈레톤 UI를 보여줍니다.
        if (viewModel.state == NotifierState.loading &&
            viewModel.articles.isEmpty) {
          return ListView.builder(
            itemCount: 10, // 처음에 보여줄 스켈레톤 카드의 개수
            itemBuilder: (context, index) => const NewsCardSkeleton(),
          );
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
                        color: article.isRead
                            ? Colors.grey.shade600
                            : Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      article.formattedPubDate,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  onTap: () {
                    viewModel.markArticleAsRead(article);
                    _readArticleService.addReadArticle(article.content);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ReaderPopup(article: article);
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