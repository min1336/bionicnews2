import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class NewsScraperService {
  Future<String> scrapeArticleContent(String url) async {
    // 1. 네이버 뉴스 URL이 아니면 스크래핑을 시도하지 않고 메시지 반환 (선택적)
    if (!url.contains('news.naver.com')) {
      return '네이버 뉴스 기사만 지원합니다.';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dom.Document document = html_parser.parse(response.body);

        // ★★★ 여기가 수정된 부분입니다 ★★★
        // 2. 오직 네이버 뉴스 본문의 선택자 '#dic_area'만 사용
        final articleElement = document.querySelector('#dic_area');

        if (articleElement != null) {
          // 3. 네이버 뉴스 기사 내의 불필요한 요소들을 제거
          const List<String> junkSelectors = [
            'script',
            'style',
            '.media_end_head_info_datestamp', // 날짜
            '.media_end_head_journalist', // 기자 정보
            '.news_end_st', // 관련 뉴스 섹션
            'a.media_end_head_press_logo', // 언론사 로고
          ];

          for (final selector in junkSelectors) {
            articleElement.querySelectorAll(selector).forEach((element) {
              element.remove();
            });
          }

          // 깨끗해진 컨테이너에서 텍스트를 추출하고 공백 정리
          return articleElement.text.trim().replaceAll(RegExp(r'\s{2,}'), ' ');
        } else {
          // 네이버 뉴스 페이지이지만 본문 컨테이너를 찾지 못한 경우
          return '네이버 뉴스 본문을 찾을 수 없습니다.';
        }
      } else {
        return '기사 페이지를 불러오는 데 실패했습니다.';
      }
    } catch (e) {
      return '기사 본문을 불러오는 중 오류가 발생했습니다.';
    }
  }
}