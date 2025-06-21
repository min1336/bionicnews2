import 'package:intl/intl.dart';

class NewsArticle {
  final String title;
  final String author;
  final String description;
  final String urlToImage;
  final String content; // This field holds the article URL
  final String sourceName;
  final String pubDate;
  bool isRead;

  NewsArticle({
    required this.title,
    required this.author,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.sourceName,
    required this.pubDate,
    this.isRead = false,
  });

  String get formattedPubDate {
    try {
      final DateTime parsedDate =
      DateFormat("E, d MMM yyyy HH:mm:ss Z", "en_US").parse(pubDate);
      return DateFormat('yyyy.MM.dd HH:mm').format(parsedDate);
    } catch (e) {
      return pubDate;
    }
  }

  // ★★★ 여기가 추가된 부분입니다: 객체를 Map으로 변환 (JSON 인코딩용) ★★★
  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'description': description,
    'urlToImage': urlToImage,
    'content': content,
    'sourceName': sourceName,
    'pubDate': pubDate,
    'isRead': isRead,
  };

  // ★★★ 여기가 추가된 부분입니다: Map으로부터 객체 생성 (JSON 디코딩용) ★★★
  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
    title: json['title'],
    author: json['author'],
    description: json['description'],
    urlToImage: json['urlToImage'],
    content: json['content'],
    sourceName: json['sourceName'],
    pubDate: json['pubDate'],
    isRead: json['isRead'] ?? false,
  );

  static String _cleanHtmlString(String htmlString) {
    final strippedString = htmlString.replaceAll(RegExp(r"<[^>]*>"), '');
    final decodedString = strippedString
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'");
    return decodedString;
  }

  // ★★★ 여기가 수정된 부분입니다: 기존 fromJson의 이름을 변경하여 역할 분리 ★★★
  factory NewsArticle.fromNaverJson(Map<String, dynamic> json, {bool isRead = false}) {
    final cleanedTitle = _cleanHtmlString(json['title'] ?? '제목 없음');
    final cleanedDesc = _cleanHtmlString(json['description'] ?? '내용 없음');

    return NewsArticle(
      title: cleanedTitle,
      author: '',
      description: cleanedDesc,
      urlToImage: '',
      content: json['link'] ?? '',
      sourceName: json['originallink'] ?? '',
      pubDate: json['pubDate'] ?? '',
      isRead: isRead,
    );
  }
}