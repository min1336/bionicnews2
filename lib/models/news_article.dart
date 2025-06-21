import 'package:intl/intl.dart';

class NewsArticle {
  final String title;
  final String author;
  final String description;
  final String urlToImage;
  final String content; // This field holds the article URL
  final String sourceName;
  final String pubDate;
  bool isRead; // ★★★ ADDED: To track if the article has been read ★★★

  NewsArticle({
    required this.title,
    required this.author,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.sourceName,
    required this.pubDate,
    this.isRead = false, // ★★★ ADDED: Default to false ★★★
  });

  /// pubDate 문자열을 'yyyy.MM.dd HH:mm' 형식으로 변환하는 getter.
  /// 파싱에 실패할 경우 원본 문자열을 반환합니다.
  String get formattedPubDate {
    try {
      final DateTime parsedDate =
      DateFormat("E, d MMM yyyy HH:mm:ss Z", "en_US").parse(pubDate);
      return DateFormat('yyyy.MM.dd HH:mm').format(parsedDate);
    } catch (e) {
      return pubDate;
    }
  }

  static String _cleanHtmlString(String htmlString) {
    final strippedString =
    htmlString.replaceAll(RegExp(r"<[^>]*>"), '');
    final decodedString = strippedString
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'");
    return decodedString;
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json, {bool isRead = false}) {
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
      isRead: isRead, // ★★★ ADDED: Set from parameter ★★★
    );
  }
}