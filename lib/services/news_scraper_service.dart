import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class NewsScraperService {
  // ★★★ 여기가 수정된 부분입니다: 'static' 키워드 추가 ★★★
  // 스크래핑 실패 시 ViewModel에서 식별할 수 있도록 static 상수로 변경합니다.
  static const String parsingFailedError = "Error: Content parsing failed.";
  static const String requestFailedError = "Error: Failed to load page.";
  static const String exceptionError = "Error: Scraping exception.";

  Future<String> scrapeArticleContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dom.Document document = html_parser.parse(response.body);

        const List<String> contentSelectors = [
          '#news_content',
          '.newsct_body',
          '#newsEndView',
          '#dic_area',
          '[itemprop="articleBody"]',
          '#article-view-content-div',
          '#articeBody',
          '#newsEndContents',
          '.article_body',
          'article',
        ];

        dom.Element? articleElement;
        for (final selector in contentSelectors) {
          articleElement = document.querySelector(selector);
          if (articleElement != null) {
            print("Found content container with selector: $selector");
            break;
          }
        }

        if (articleElement != null) {
          const List<String> junkSelectors = [
            'script',
            'style',
            '.ad_section',
            '.article-info',
            '.social_share',
            '.tag-group',
            '.copyright',
            '.reporter_area',
            '.news_end_st'
          ];

          for (final selector in junkSelectors) {
            articleElement.querySelectorAll(selector).forEach((element) {
              element.remove();
            });
          }

          return articleElement.text.trim().replaceAll(RegExp(r'\s{2,}'), ' ');
        } else {
          print("Could not find a specific content container for URL: $url. Failing.");
          return parsingFailedError;
        }

      } else {
        print('Failed to load URL: $url, status code: ${response.statusCode}');
        return requestFailedError;
      }
    } catch (e) {
      print('Error scraping URL: $url, error: $e');
      return exceptionError;
    }
  }
}