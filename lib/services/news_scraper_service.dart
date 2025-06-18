import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;


class NewsScraperService {
  Future<String> scrapeArticleContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dom.Document document = html_parser.parse(response.body);
        // 네이버 뉴스 본문이 <article> 태그 안에 있는 경우가 많습니다.
        final articleElement = document.querySelector('article');
        if (articleElement != null) {
          // <article> 태그 안의 모든 텍스트를 추출하여 공백을 정리합니다.
          return articleElement.text.trim().replaceAll('\s+', ' ');
        } else {
          // <article> 태그가 없으면 body 전체에서 텍스트를 추출 시도
          return document.body?.text.trim().replaceAll('\s+', ' ') ?? '';
        }
      } else {
        print('Failed to load URL: $url, status code: ${response.statusCode}');
        return 'Failed to load article content.';
      }
    } catch (e) {
      print('Error scraping URL: $url, error: $e');
      return 'Error loading article content.';
    }
  }
}