import 'package:meta/meta.dart';

@immutable
class Label {
  final String id;
  final String name;
  final String hexColor;
  final int count;

  const Label({
    required this.id,
    required this.name,
    required this.hexColor,
    this.count = 0,
  });

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      hexColor: json['hexColor'] as String? ?? '#FFFFFF',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hexColor': hexColor,
        'count': count,
      };
}
