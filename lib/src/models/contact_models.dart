import 'package:meta/meta.dart';

@immutable
class Contact {
  final String id;
  final String? name;
  final String? shortName;
  final String? pushName;
  final String? formattedName;
  final bool isBusiness;
  final bool isEnterprise;
  final String? profilePicUrl;
  final bool isBlocked;

  const Contact({
    required this.id,
    this.name,
    this.shortName,
    this.pushName,
    this.formattedName,
    this.isBusiness = false,
    this.isEnterprise = false,
    this.profilePicUrl,
    this.isBlocked = false,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String? ?? json['_serialized'] as String? ?? '',
      name: json['name'] as String?,
      shortName: json['shortName'] as String?,
      pushName: json['pushname'] as String?,
      formattedName: json['formattedName'] as String?,
      isBusiness: json['isBusiness'] as bool? ?? false,
      isEnterprise: json['isEnterprise'] as bool? ?? false,
      profilePicUrl: json['profilePic'] as String? ?? json['profilePicUrl'] as String?,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'pushName': pushName,
        'formattedName': formattedName,
        'isBusiness': isBusiness,
        'isEnterprise': isEnterprise,
        'profilePicUrl': profilePicUrl,
        'isBlocked': isBlocked,
      };
}

@immutable
class NumberStatus {
  final String id;
  final bool isRegistered;
  final bool numberExists;
  final String? formattedJid;

  const NumberStatus({
    required this.id,
    required this.isRegistered,
    required this.numberExists,
    this.formattedJid,
  });

  factory NumberStatus.fromJson(Map<String, dynamic> json) {
    return NumberStatus(
      id: json['id']?['_serialized'] as String? ?? json['id'] as String? ?? '',
      isRegistered: json['isBusiness'] as bool? ?? json['numberExists'] as bool? ?? json['canReceiveMessage'] as bool? ?? false,
      numberExists: json['numberExists'] as bool? ?? true,
      formattedJid: json['jid'] as String? ?? json['id']?['_serialized'] as String?,
    );
  }
}
