import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsApiService {
  // ★★★ 1. 여기에 발급받은 네이버 Client ID와 Secret을 입력하세요 ★★★
  final String _clientId = 'SzY2pztqNJ1SC0mLTz7p';
  final String _clientSecret = 'SeO1KbU18D';

  final String _baseUrl = 'https://openapi.naver.com/v1/search/news.json';

  Future<List<NewsArticle>> fetchNews(String query) async {
    // ★★★ 바로 이 부분의 display 값을 100으로 변경합니다 ★★★
    final url = '$_baseUrl?query=${Uri.encodeComponent(query)}&display=100'; // 20 -> 100
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
      // ★ 4. 'articles' 대신 'items' 키에서 데이터를 가져옴 ★
      final List<dynamic> articlesJson = json['items'];

      return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
    } else {
      throw Exception('뉴스를 불러오는 데 실패했습니다: ${response.body}');
    }
  }
}