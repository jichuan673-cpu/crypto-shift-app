class Article {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final String date;
  final String link;
  final String? thumbnailUrl;
  final int? featuredMedia;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.date,
    required this.link,
    this.thumbnailUrl,
    this.featuredMedia,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    String rawTitle = json['title']?['rendered'] ?? '';
    String rawContent = json['content']?['rendered'] ?? '';
    String rawExcerpt = json['excerpt']?['rendered'] ?? '';

      final sizes = json['_embedded']?['wp:featuredmedia']?[0]?['media_details']?['sizes'];
      String? thumbnailUrl = sizes?['medium_large']?['source_url'] ?? sizes?['medium']?['source_url'] ?? sizes?['full']?['source_url'] ?? json['_embedded']?['wp:featuredmedia']?[0]?['source_url'];

      return Article(
        id: json['id'],
        title: _stripHtml(rawTitle),
        content: rawContent,
        excerpt: _stripHtml(rawExcerpt),
        date: json['date'] ?? '',
        link: json['link'] ?? '',
        thumbnailUrl: thumbnailUrl,
      featuredMedia: json['featured_media'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'date': date,
      'link': link,
      'thumbnailUrl': thumbnailUrl,
      'featuredMedia': featuredMedia,
    };
  }

  factory Article.fromJsonLocal(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      excerpt: json['excerpt'],
      date: json['date'],
      link: json['link'],
      thumbnailUrl: json['thumbnailUrl'],
      featuredMedia: json['featuredMedia'],
    );
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}
