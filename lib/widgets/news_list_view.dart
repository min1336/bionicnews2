import 'package:focus_news/models/news_article.dart';
import 'package:focus_news/services/read_article_service.dart';
import 'package:focus_news/viewmodels/news_viewmodel.dart';
import 'package:focus_news/widgets/error_display_widget.dart';
import 'package:focus_news/widgets/news_card_skeleton.dart';
import 'package:focus_news/widgets/reader_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        if (viewModel.state == NotifierState.loading &&
            viewModel.articles.isEmpty) {
          return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => const NewsCardSkeleton(),
          );
        }

        if (viewModel.state == NotifierState.error &&
            viewModel.articles.isEmpty) {
          return ErrorDisplayWidget(
            errorMessage: viewModel.errorMessage,
            onRetry: () {
              if (viewModel.currentQuery != null) {
                viewModel.fetchNews(viewModel.currentQuery!, isRefresh: true);
              }
            },
          );
        }

        if (viewModel.articles.isEmpty &&
            viewModel.state == NotifierState.loaded) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  '뉴스가 없습니다.',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '다른 주제를 선택하거나 검색어를 변경해보세요.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey.shade500),
                )
              ],
            ),
          );
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
                    _readArticleService.addReadArticle(article.articleUrl);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ReaderPopup(article: article);
                      },
                    );
                  },
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, curve: Curves.easeIn)
                  .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeInOut);
            },
          ),
        );
      },
    );
  }
}