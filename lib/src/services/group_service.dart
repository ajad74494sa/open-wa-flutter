import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/group_models.dart';

/// Service for creating, configuring, and managing WhatsApp Groups & Participants.
class GroupService {
  final OpenWaHttpClient _client;

  GroupService(this._client);

  /// Creates a new group with specified name and initial members.
  Future<ApiResponse<GroupMetadata>> createGroup(
    String groupName,
    List<String> participantIds,
  ) async {
    return _client.post<GroupMetadata>(
      '/groups/create',
      body: {
        'groupName': groupName,
        'participants': participantIds,
      },
      parser: (json) => GroupMetadata.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches group metadata, participant list, admin status, and settings.
  Future<ApiResponse<GroupMetadata>> getGroupMetadata(String groupId) async {
    return _client.get<GroupMetadata>(
      '/groups/$groupId',
      parser: (json) => GroupMetadata.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Adds new participants to an existing group.
  Future<ApiResponse<bool>> addParticipants(
    String groupId,
    List<String> participantIds,
  ) async {
    return _client.post<bool>(
      '/groups/addParticipants',
      body: {
        'groupId': groupId,
        'participants': participantIds,
      },
      parser: (json) => json['added'] as bool? ?? true,
    );
  }

  /// Removes participants from a group.
  Future<ApiResponse<bool>> removeParticipants(
    String groupId,
    List<String> participantIds,
  ) async {
    return _client.post<bool>(
      '/groups/removeParticipants',
      body: {
        'groupId': groupId,
        'participants': participantIds,
      },
      parser: (json) => json['removed'] as bool? ?? true,
    );
  }

  /// Promotes participants to group admin role.
  Future<ApiResponse<bool>> promoteParticipants(
    String groupId,
    List<String> participantIds,
  ) async {
    return _client.post<bool>(
      '/groups/promote',
      body: {
        'groupId': groupId,
        'participants': participantIds,
      },
      parser: (json) => json['promoted'] as bool? ?? true,
    );
  }

  /// Demotes admins back to standard group participants.
  Future<ApiResponse<bool>> demoteParticipants(
    String groupId,
    List<String> participantIds,
  ) async {
    return _client.post<bool>(
      '/groups/demote',
      body: {
        'groupId': groupId,
        'participants': participantIds,
      },
      parser: (json) => json['demoted'] as bool? ?? true,
    );
  }

  /// Generates or retrieves the group invite URL link.
  Future<ApiResponse<String>> getInviteLink(String groupId) async {
    return _client.get<String>(
      '/groups/$groupId/inviteLink',
      parser: (json) => json['inviteLink'] as String? ?? json['code'] as String? ?? '',
    );
  }

  /// Revokes current group invite link and generates a new one.
  Future<ApiResponse<String>> revokeInviteLink(String groupId) async {
    return _client.post<String>(
      '/groups/$groupId/revokeInviteLink',
      parser: (json) => json['inviteLink'] as String? ?? json['code'] as String? ?? '',
    );
  }

  /// Joins a group using an invite code or link.
  Future<ApiResponse<GroupMetadata>> joinGroupViaInvite(String inviteCode) async {
    final cleanCode = inviteCode.split('/').last;
    return _client.post<GroupMetadata>(
      '/groups/join',
      body: {'inviteCode': cleanCode},
      parser: (json) => GroupMetadata.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Leaves a group.
  Future<ApiResponse<bool>> leaveGroup(String groupId) async {
    return _client.post<bool>(
      '/groups/leave',
      body: {'groupId': groupId},
      parser: (json) => json['left'] as bool? ?? true,
    );
  }

  /// Updates the group subject title.
  Future<ApiResponse<bool>> setGroupTitle(String groupId, String newTitle) async {
    return _client.post<bool>(
      '/groups/setSubject',
      body: {
        'groupId': groupId,
        'subject': newTitle,
      },
      parser: (json) => json['updated'] as bool? ?? true,
    );
  }

  /// Updates group description text.
  Future<ApiResponse<bool>> setGroupDescription(String groupId, String description) async {
    return _client.post<bool>(
      '/groups/setDescription',
      body: {
        'groupId': groupId,
        'description': description,
      },
      parser: (json) => json['updated'] as bool? ?? true,
    );
  }

  /// Updates group icon profile image via media upload.
  Future<ApiResponse<bool>> setGroupPhoto(
    String groupId,
    List<int> imageBytes,
    String fileName,
  ) async {
    return _client.uploadMedia<bool>(
      '/groups/setIcon',
      fieldName: 'file',
      fileBytes: imageBytes,
      fileName: fileName,
      extraFields: {'groupId': groupId},
      parser: (json) => json['updated'] as bool? ?? true,
    );
  }
}
