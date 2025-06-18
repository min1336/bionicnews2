import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_api_service.dart'; // API 서비스 import
import '../widgets/bionic_reading_popup.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final NewsApiService _newsApiService = NewsApiService();
  late Future<List<NewsArticle>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    // ★ 서비스 함수를 fetchNews로 변경하고, 검색어를 전달 (예: 'IT') ★
    _articlesFuture = _newsApiService.fetchNews('IT');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bionic Reading 뉴스피드'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      // FutureBuilder를 사용하여 비동기 데이터 로딩 상태를 처리
      body: FutureBuilder<List<NewsArticle>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // --- 데이터 로딩 중일 때 ---
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // --- 에러가 발생했을 때 ---
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // --- 데이터가 없을 때 ---
            return const Center(child: Text('뉴스가 없습니다.'));
          } else {
            // --- 데이터 로딩이 완료되었을 때 ---
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4,
                  clipBehavior: Clip.antiAlias, // Card의 자식 위젯이 Card 모양을 따르도록 함
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
                      child: Text('출처: ${article.sourceName}'),
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
            );
          }
        },
      ),
    );
  }
}