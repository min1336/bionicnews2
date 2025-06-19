import 'package:bionic_news/models/news_article.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class NewsScraperService {
  Future<String> scrapeArticleContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dom.Document document = html_parser.parse(response.body);

        const List<String> contentSelectors = [
          '[itemprop="articleBody"]',
          '#article-view-content-div',
          '#dic_area',
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
          // ★★★ 여기가 수정된 부분입니다 ★★★
          // '.social-' 오타를 '.social_share' 등으로 수정합니다.
          const List<String> junkSelectors = [
            'script',
            'style',
            '.ad_section',
            '.article-info',
            '.social_share', // 소셜 공유 버튼 영역
            '.tag-group',
            '.copyright', // 저작권 문구 클래스
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
          print("Could not find content with specific selectors, falling back to body.");
          return document.body?.text.trim().replaceAll(RegExp(r'\s{2,}'), ' ') ??
              '본문을 찾을 수 없습니다.';
        }

      } else {
        print('Failed to load URL: $url, status code: ${response.statusCode}');
        return '기사 본문을 불러오는 데 실패했습니다.';
      }
    } catch (e) {
      print('Error scraping URL: $url, error: $e');
      return '기사 본문을 불러오는 중 오류가 발생했습니다.';
    }
  }
}