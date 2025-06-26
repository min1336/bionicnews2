import 'package:intl/intl.dart';

class NewsArticle {
  final String title;
  final String author;
  final String description;
  final String urlToImage;
  final String articleUrl;
  final String originalLink;
  final String pubDate;
  bool isRead;

  NewsArticle({
    required this.title,
    required this.author,
    required this.description,
    required this.urlToImage,
    required this.articleUrl,
    required this.originalLink,
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

  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'description': description,
    'urlToImage': urlToImage,
    'articleUrl': articleUrl,
    'originalLink': originalLink,
    'pubDate': pubDate,
    'isRead': isRead,
  };

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
    title: json['title'] ?? '제목 없음',
    author: json['author'] ?? '',
    description: json['description'] ?? '내용 없음',
    urlToImage: json['urlToImage'] ?? '',
    articleUrl: json['articleUrl'] ?? '',
    originalLink: json['originalLink'] ?? '',
    pubDate: json['pubDate'] ?? '',
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

  factory NewsArticle.fromNaverJson(Map<String, dynamic> json,
      {bool isRead = false}) {
    final cleanedTitle = _cleanHtmlString(json['title'] ?? '제목 없음');
    final cleanedDesc = _cleanHtmlString(json['description'] ?? '내용 없음');

    return NewsArticle(
      title: cleanedTitle,
      author: '',
      description: cleanedDesc,
      urlToImage: '',
      articleUrl: json['link'] ?? '',
      originalLink: json['originallink'] ?? '',
      pubDate: json['pubDate'] ?? '',
      isRead: isRead,
    );
  }
}