import 'package:bionic_news/models/news_article.dart';
import 'package:bionic_news/services/news_api_service.dart';
import 'package:bionic_news/widgets/bionic_reading_popup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewsTopicList extends StatefulWidget {
  final String query;
  const NewsTopicList({super.key, required this.query});

  @override
  State<NewsTopicList> createState() => _NewsTopicListState();
}

class _NewsTopicListState extends State<NewsTopicList> with AutomaticKeepAliveClientMixin {
  final NewsApiService _newsApiService = NewsApiService();
  final ScrollController _scrollController = ScrollController();

  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _start = 1;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadInitialNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialNews() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final newArticles = await _newsApiService.fetchNews(widget.query, start: 1);
      if (!mounted) return;
      setState(() {
        _articles.clear();
        _articles.addAll(newArticles);
        _start = 1;
        _hasMore = newArticles.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ★★★ 1. 새로고침을 위한 별도 함수 생성 ★★★
  Future<void> _refreshNews() async {
    try {
      final newArticles = await _newsApiService.fetchNews(widget.query, start: 1);
      if (!mounted) return;
      setState(() {
        _articles.clear();
        _articles.addAll(newArticles);
        _start = 1;
        _hasMore = newArticles.isNotEmpty;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newArticles = await _newsApiService.fetchNews(widget.query, start: _start + 100);
      if (!mounted) return;
      setState(() {
        _articles.addAll(newArticles);
        _start += 100;
        _hasMore = newArticles.isNotEmpty;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _error = e.toString();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNews();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty && _articles.isEmpty) {
      return Center(child: Text('오류가 발생했습니다: $_error'));
    }

    if (_articles.isEmpty) {
      return const Center(child: Text('뉴스가 없습니다.'));
    }

    // ★★★ 2. ListView.builder를 RefreshIndicator로 감싸기 ★★★
    return RefreshIndicator(
      onRefresh: _refreshNews, // 당겼을 때 _refreshNews 함수 호출
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _articles.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _articles.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final article = _articles[index];
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
  }
}