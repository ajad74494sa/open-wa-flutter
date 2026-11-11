import 'package:meta/meta.dart';

@immutable
class Product {
  final String id;
  final String name;
  final String price;
  final String? description;
  final String currency;
  final bool isHidden;
  final List<String> imageUrls;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.currency = 'USD',
    this.isHidden = false,
    required this.imageUrls,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = json['imageUrls'] as List<dynamic>? ?? json['images'] as List<dynamic>? ?? [];
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      price: json['price'] as String? ?? '0',
      description: json['description'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      isHidden: json['isHidden'] as bool? ?? false,
      imageUrls: images.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'currency': currency,
        'isHidden': isHidden,
        'imageUrls': imageUrls,
      };
}
