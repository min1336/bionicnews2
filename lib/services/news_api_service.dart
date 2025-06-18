import 'dart:convert';
import 'package:bionic_news/models/news_article.dart';
import 'package:http/http.dart' as http;

class NewsApiService {
  // ★★★ 1. 여기에 발급받은 네이버 Client ID와 Secret을 입력하세요 ★★★
  final String _clientId = 'SzY2pztqNJ1SC0mLTz7p';
  final String _clientSecret = 'SeO1KbU18D';

  final String _baseUrl = 'https://openapi.naver.com/v1/search/news.json';

  Future<List<NewsArticle>> fetchNews(String query) async {
    final url = '$_baseUrl?query=${Uri.encodeComponent(query)}&display=100';
    print('Requesting URL: $url');

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
      final List<dynamic> articlesJson = json['items'];

      // ★★★ 여기가 수정된 부분입니다 ★★★
      // API 응답 결과에서 네이버 뉴스 링크를 가진 기사만 필터링합니다.
      final filteredArticles = articlesJson.where((article) {
        final link = article['link'] as String?;
        return link != null && link.startsWith('https://news.naver.com');
      }).toList();

      // 필터링된 목록을 NewsArticle 객체로 변환합니다.
      return filteredArticles
          .map((json) => NewsArticle.fromJson(json))
          .toList();
    } else {
      throw Exception('뉴스를 불러오는 데 실패했습니다: ${response.body}');
    }
  }
}