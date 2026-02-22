/// Model class for marketing cards
class MarketingCard {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int order;

  MarketingCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.order,
  });

  /// Create a MarketingCard from JSON
  factory MarketingCard.fromJson(Map<String, dynamic> json) {
    return MarketingCard(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String,
      order: json['order'] as int,
    );
  }

  /// Convert MarketingCard to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'order': order,
    };
  }
}
