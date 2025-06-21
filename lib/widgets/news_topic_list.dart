import 'package:bionic_news/models/news_article.dart';
import 'package:bionic_news/viewmodels/news_viewmodel.dart';
import 'package:bionic_news/widgets/bionic_reading_popup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewsTopicList extends StatelessWidget {
  final String query;
  const NewsTopicList({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsViewModel()..fetchNews(query, isRefresh: true),
      child: const _NewsTopicListView(),
    );
  }
}

class _NewsTopicListView extends StatefulWidget {
  const _NewsTopicListView();

  @override
  State<_NewsTopicListView> createState() => _NewsTopicListViewState();
}

class _NewsTopicListViewState extends State<_NewsTopicListView> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      context.read<NewsViewModel>().fetchNews(context.read<NewsViewModel>().currentQuery!);
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
        if (viewModel.state == NotifierState.loading && viewModel.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.state == NotifierState.error && viewModel.articles.isEmpty) {
          return Center(child: Text('오류가 발생했습니다: ${viewModel.errorMessage}'));
        }

        if (viewModel.articles.isEmpty && viewModel.state == NotifierState.loaded) {
          return const Center(child: Text('뉴스가 없습니다.'));
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.fetchNews(viewModel.currentQuery!, isRefresh: true),
          child: ListView.builder(
            controller: _scrollController,
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
                formattedDate = DateFormat('yyyy년 MM월 dd일 HH:mm').format(parsedDate);
              } catch (e) {
                formattedDate = article.pubDate;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    article.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[600]),
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
    );
  }
}