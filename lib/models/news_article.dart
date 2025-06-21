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