class NewsArticle {
  final String title;
  final String author;
  final String description;
  final String urlToImage;
  final String content;
  final String sourceName;
  final String pubDate; // ★★★ 1. pubDate 필드 추가 ★★★

  NewsArticle({
    required this.title,
    required this.author,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.sourceName,
    required this.pubDate, // ★★★ 2. 생성자에 추가 ★★★
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

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final cleanedTitle = _cleanHtmlString(json['title'] ?? '제목 없음');
    final cleanedDesc = _cleanHtmlString(json['description'] ?? '내용 없음');

    return NewsArticle(
      title: cleanedTitle,
      author: '',
      description: cleanedDesc,
      urlToImage: '',
      content: json['link'] ?? '',
      sourceName: json['originallink'] ?? '',
      pubDate: json['pubDate'] ?? '', // ★★★ 3. JSON에서 pubDate 값 파싱 ★★★
    );
  }
}