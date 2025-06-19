import 'dart:convert';
import 'package:bionic_news/models/news_article.dart';
import 'package:http/http.dart' as http;

class NewsApiService {
  final String _clientId = 'SzY2pztqNJ1SC0mLTz7p';
  final String _clientSecret = 'SeO1KbU18D';

  final String _baseUrl = 'https://openapi.naver.com/v1/search/news.json';

  // ★★★ 여기가 수정된 부분입니다 (start 파라미터 추가) ★★★
  Future<List<NewsArticle>> fetchNews(String query, {int start = 1}) async {
    // start 파라미터를 URL에 추가합니다.
    final url = '$_baseUrl?query=${Uri.encodeComponent(query)}&display=100&start=$start';
    print('Requesting URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Naver-Client-Id': _clientId,
          'X-Naver-Client-Secret': _clientSecret,
        },
      );

      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> json = jsonDecode(responseBody);
        final List<dynamic> articlesJson = json['items'] ?? [];

        final filteredArticles = articlesJson.where((article) {
          final link = article['link'] as String?;
          return link != null && link.contains('naver.com');
        }).toList();

        final uniqueArticles = _removeDuplicates(filteredArticles);

        print('Total articles received: ${articlesJson.length}');
        print('Unique articles after de-duplication: ${uniqueArticles.length}');

        return uniqueArticles
            .map((json) => NewsArticle.fromJson(json))
            .toList();
      } else {
        print('API Error Response Body: ${utf8.decode(response.bodyBytes)}');
        throw Exception('API로부터 잘못된 응답을 받았습니다.');
      }
    } catch (e) {
      print('네트워크 요청 중 오류 발생: $e');
      throw Exception('네트워크 요청 중 오류가 발생했습니다.');
    }
  }

  // 중복 제거 로직을 별도 함수로 분리 (가독성 향상)
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