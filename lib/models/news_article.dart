import 'dart:convert';

class NewsArticle {
  final String title;
  final String author; // 네이버 API는 author를 제공하지 않음
  final String description;
  final String urlToImage;  // 네이버 API는 이미지를 제공하지 않음
  final String content;     // 네이버 API는 link를 content로 활용
  final String sourceName;  // 네이버 API는 source를 제공하지 않음

  NewsArticle({
    required this.title,
    required this.author,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.sourceName,
  });

  // HTML 태그를 제거하는 헬퍼 함수
  static String _stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  // 네이버 API의 JSON 구조에 맞게 수정
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    // 네이버 뉴스 제목/설명에 포함된 HTML 엔티티를 디코딩하고 태그를 제거
    final unescapedTitle = _stripHtmlTags(json['title'] ?? '제목 없음');
    final unescapedDesc = _stripHtmlTags(json['description'] ?? '내용 없음');

    return NewsArticle(
      title: unescapedTitle,
      author: '', // 저자 정보 없음
      description: unescapedDesc,
      urlToImage: '', // 이미지 정보 없음
      content: json['link'] ?? '', // content 대신 기사 링크를 저장
      sourceName: json['originallink'] ?? '', // source 대신 원본 링크를 저장
    );
  }
}