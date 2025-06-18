import 'package:bionic_news/models/news_article.dart';
import 'package:bionic_news/services/news_api_service.dart';
import 'package:bionic_news/widgets/bionic_reading_popup.dart';
import 'package:flutter/material.dart';

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
    // ★★★ 여기가 수정된 부분입니다 ★★★
    // 검색어를 'IT'에서 '뉴스'로 변경하여 더 일반적인 한국 뉴스를 검색합니다.
    _articlesFuture = _newsApiService.fetchNews('뉴스');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bionic Reading 뉴스피드'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<NewsArticle>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('뉴스가 없습니다.'));
          } else {
            final articles = snapshot.data!;
            // 'ListView.builder'는 내용이 화면을 넘어가면 자동으로 스크롤 기능을 제공합니다.
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      article.title,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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