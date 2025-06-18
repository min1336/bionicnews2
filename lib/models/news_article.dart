import 'dart:convert';

class NewsArticle {
  final String title;
  final String author; // 네이버 API는 author를 제공하지 않음
  final String description;
  final String urlToImage; // 네이버 API는 이미지를 제공하지 않음
  final String content; // 네이버 API는 link를 content로 활용
  final String sourceName; // 네이버 API는 source를 제공하지 않음

  NewsArticle({
    required this.title,
    required this.author,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.sourceName,
  });

  // ★★★ 여기가 수정된 부분입니다 ★★★
  // HTML 태그 제거와 엔티티 변환을 모두 처리하는 함수
  static String _cleanHtmlString(String htmlString) {
    // 1. HTML 태그 제거 (예: <b>, </b>)
    final strippedString =
    htmlString.replaceAll(RegExp(r"<[^>]*>"), '');

    // 2. 주요 HTML 엔티티를 실제 문자로 변환
    final decodedString = strippedString
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'"); // 작은따옴표의 다른 형태

    return decodedString;
  }

  // 네이버 API의 JSON 구조에 맞게 수정
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    // 수정된 _cleanHtmlString 함수를 사용하여 제목과 설명을 처리
    final cleanedTitle = _cleanHtmlString(json['title'] ?? '제목 없음');
    final cleanedDesc = _cleanHtmlString(json['description'] ?? '내용 없음');

    return NewsArticle(
      title: cleanedTitle,
      author: '', // 저자 정보 없음
      description: cleanedDesc,
      urlToImage: '', // 이미지 정보 없음
      content: json['link'] ?? '', // content 대신 기사 링크를 저장
      sourceName: json['originallink'] ?? '', // source 대신 원본 링크를 저장
    );
  }
}