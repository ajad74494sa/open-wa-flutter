import 'package:meta/meta.dart';

@immutable
class GroupParticipant {
  final String id;
  final bool isAdmin;
  final bool isSuperAdmin;

  const GroupParticipant({
    required this.id,
    this.isAdmin = false,
    this.isSuperAdmin = false,
  });

  factory GroupParticipant.fromJson(Map<String, dynamic> json) {
    return GroupParticipant(
      id: json['id']?['_serialized'] as String? ?? json['id'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
      isSuperAdmin: json['isSuperAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isAdmin': isAdmin,
        'isSuperAdmin': isSuperAdmin,
      };
}

@immutable
class GroupMetadata {
  final String id;
  final String owner;
  final String subject;
  final String? description;
  final int creationTimestamp;
  final List<GroupParticipant> participants;
  final String? inviteLink;
  final bool isReadOnly;
  final bool announce;

  const GroupMetadata({
    required this.id,
    required this.owner,
    required this.subject,
    this.description,
    required this.creationTimestamp,
    required this.participants,
    this.inviteLink,
    this.isReadOnly = false,
    this.announce = false,
  });

  factory GroupMetadata.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'] as List<dynamic>? ?? [];
    return GroupMetadata(
      id: json['id']?['_serialized'] as String? ?? json['id'] as String? ?? '',
      owner: json['owner']?['_serialized'] as String? ?? json['owner'] as String? ?? '',
      subject: json['subject'] as String? ?? json['name'] as String? ?? '',
      description: json['desc'] as String? ?? json['description'] as String?,
      creationTimestamp: json['creation'] as int? ?? 0,
      participants: rawParticipants
          .map((p) => GroupParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
      inviteLink: json['inviteCode'] as String?,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
      announce: json['announce'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner': owner,
        'subject': subject,
        'description': description,
        'creationTimestamp': creationTimestamp,
        'participants': participants.map((p) => p.toJson()).toList(),
        'inviteLink': inviteLink,
        'isReadOnly': isReadOnly,
        'announce': announce,
      };
}
