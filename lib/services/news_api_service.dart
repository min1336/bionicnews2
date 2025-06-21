import 'dart:convert';
import 'package:bionic_news/models/news_article.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NewsApiService {
  final String _clientId = dotenv.env['NAVER_CLIENT_ID'] ?? '';
  final String _clientSecret = dotenv.env['NAVER_CLIENT_SECRET'] ?? '';
  final String _baseUrl = 'https://openapi.naver.com/v1/search/news.json';

  // ★★★ FIXED: display 파라미터를 함수 정의에 추가합니다. ★★★
  Future<List<NewsArticle>> fetchNews(String query, {int start = 1, int display = 100}) async {
    final url = '$_baseUrl?query=${Uri.encodeComponent(query)}&display=$display&start=$start';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Naver-Client-Id': _clientId,
          'X-Naver-Client-Secret': _clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> json = jsonDecode(responseBody);
        final List<dynamic> articlesJson = json['items'] ?? [];

        final filteredArticles = articlesJson.where((article) {
          final link = article['link'] as String?;
          return link != null && link.contains('naver.com');
        }).toList();

        final uniqueArticles = _removeDuplicates(filteredArticles);

        return uniqueArticles
            .map((json) => NewsArticle.fromJson(json))
            .toList();
      } else {
        throw Exception('API로부터 잘못된 응답을 받았습니다 (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('네트워크 요청 중 오류가 발생했습니다: $e');
    }
  }

  List<dynamic> _removeDuplicates(List<dynamic> articles) {
    final seenTitles = <String>{};
    final uniqueArticlesJson = <dynamic>[];
    for (final article in articles) {
      final title = article['title'] as String?;
      if (title != null && seenTitles.add(title)) {
        uniqueArticlesJson.add(article);
      }
    }
    return uniqueArticlesJson;
  }
}