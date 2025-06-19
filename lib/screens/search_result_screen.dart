import 'package:bionic_news/models/news_article.dart';
import 'package:bionic_news/services/news_api_service.dart';
import 'package:bionic_news/widgets/bionic_reading_popup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchResultScreen extends StatefulWidget {
  final String query;
  const SearchResultScreen({super.key, required this.query});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final NewsApiService _newsApiService = NewsApiService();
  final ScrollController _scrollController = ScrollController();

  final List<NewsArticle> _articles = [];
  bool _isLoading = true; // 초기 로딩 상태
  bool _isLoadingMore = false; // '더 보기' 로딩 상태
  bool _hasMore = true; // 더 불러올 데이터가 있는지 여부
  int _start = 1; // API 요청 시작 위치
  String _error = ''; // 에러 메시지

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

  // ★★★ 여기가 채워진 부분입니다 ★★★
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
      // 네이버 API는 start가 1000을 초과하면 에러를 반환하므로, 이를 방지합니다.
      if (_start >= 1000) {
        setState(() => _hasMore = false);
        return;
      }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("'${widget.query}' 검색 결과"),
        // AppBar의 배경색과 전경색을 메인 화면과 통일합니다.
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty && _articles.isEmpty) {
      return Center(child: Text('오류가 발생했습니다: $_error'));
    }

    if (_articles.isEmpty) {
      return const Center(child: Text('검색된 뉴스가 없습니다.'));
    }

    return RefreshIndicator(
      onRefresh: _refreshNews,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
  }
}