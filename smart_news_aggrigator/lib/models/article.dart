class Article {
  final String title;
  final String? author;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final String? source;

  Article({
    required this.title,
    this.author,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.source,
  });

  // Factory constructor to create Article from JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      author: json['author'],
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'])
          : null,
      content: json['content'],
      source: json['source']?['name'],
    );
  }

  // Convert Article to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'source': {'name': source},
    };
  }

  // Create a copy of the article with updated fields
  Article copyWith({
    String? title,
    String? author,
    String? description,
    String? url,
    String? urlToImage,
    DateTime? publishedAt,
    String? content,
    String? source,
  }) {
    return Article(
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      source: source ?? this.source,
    );
  }

  @override
  String toString() {
    return 'Article{title: $title, author: $author, url: $url}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article &&
        other.title == title &&
        other.author == author &&
        other.description == description &&
        other.url == url &&
        other.urlToImage == urlToImage &&
        other.publishedAt == publishedAt &&
        other.content == content &&
        other.source == source;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        author.hashCode ^
        description.hashCode ^
        url.hashCode ^
        urlToImage.hashCode ^
        publishedAt.hashCode ^
        content.hashCode ^
        source.hashCode;
  }

  // Helper method to check if the article has an image
  bool get hasImage => urlToImage != null && urlToImage!.isNotEmpty;

  // Helper method to get formatted published date
  String get formattedDate {
    if (publishedAt == null) return 'Unknown date';
    final now = DateTime.now();
    final difference = now.difference(publishedAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to get truncated description
  String getTruncatedDescription(int maxLength) {
    if (description == null || description!.isEmpty) {
      return 'No description available';
    }
    if (description!.length <= maxLength) {
      return description!;
    }
    return '${description!.substring(0, maxLength)}...';
  }
}
