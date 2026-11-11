import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/group_models.dart';

/// Session-scoped WhatsApp group and participant operations.
class GroupService {
  final OpenWaHttpClient _client;

  GroupService(this._client);

  Future<ApiResponse<List<GroupMetadata>>> getGroups(
    String sessionId, {
    int limit = 100,
    int offset = 0,
  }) {
    return _client.get<List<GroupMetadata>>(
      '/api/sessions/${_segment(sessionId)}/groups',
      queryParameters: {'limit': limit, 'offset': offset},
      parser: _parseGroups,
    );
  }

  Future<ApiResponse<GroupMetadata>> createGroup(
    String sessionId,
    String groupName,
    List<String> participantIds,
  ) {
    return _client.post<GroupMetadata>(
      '/api/sessions/${_segment(sessionId)}/groups',
      body: {'name': groupName, 'participants': participantIds},
      parser: (json) =>
          GroupMetadata.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<GroupMetadata>> getGroupMetadata(
    String sessionId,
    String groupId,
  ) {
    return _client.get<GroupMetadata>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}',
      parser: (json) =>
          GroupMetadata.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<bool>> addParticipants(
    String sessionId,
    String groupId,
    List<String> participantIds,
  ) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}/participants',
      body: {'participants': participantIds},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> removeParticipants(
    String sessionId,
    String groupId,
    List<String> participantIds,
  ) {
    return _client.delete<bool>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}/participants',
      body: {'participants': participantIds},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> promoteParticipants(
    String sessionId,
    String groupId,
    List<String> participantIds,
  ) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}/participants/promote',
      body: {'participants': participantIds},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> demoteParticipants(
    String sessionId,
    String groupId,
    List<String> participantIds,
  ) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}/participants/demote',
      body: {'participants': participantIds},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<String>> getInviteLink(String sessionId, String groupId) {
    return _client.get<String>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}/invite-code',
      parser: (json) {
        final response = json as Map<String, dynamic>;
        return response['inviteLink'] as String? ??
            response['code'] as String? ??
            '';
      },
    );
  }

  Future<ApiResponse<String>> revokeInviteLink(
    String sessionId,
    String groupId,
  ) {
    return _client.post<String>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}/invite-code/revoke',
      parser: (json) {
        final response = json as Map<String, dynamic>;
        return response['inviteLink'] as String? ??
            response['code'] as String? ??
            '';
      },
    );
  }

  Future<ApiResponse<GroupMetadata>> joinGroupViaInvite(
    String sessionId,
    String inviteCode,
  ) {
    final cleanCode = inviteCode.split('/').last;
    return _client.post<GroupMetadata>(
      '/api/sessions/${_segment(sessionId)}/groups/join',
      body: {'inviteCode': cleanCode},
      parser: (json) =>
          GroupMetadata.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<bool>> leaveGroup(String sessionId, String groupId) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}/leave',
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> setGroupTitle(
    String sessionId,
    String groupId,
    String newTitle,
  ) {
    return _client.put<bool>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}/subject',
      body: {'subject': newTitle},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> setGroupDescription(
    String sessionId,
    String groupId,
    String description,
  ) {
    return _client.put<bool>(
      '/api/sessions/${_segment(sessionId)}/groups/${_segment(groupId)}/description',
      body: {'description': description},
      parser: (_) => true,
    );
  }
}

String _segment(String value) => Uri.encodeComponent(value);

List<GroupMetadata> _parseGroups(dynamic json) {
  if (json is List) {
    return json.map((group) {
      if (group is! Map) {
        throw const FormatException('Group entries must be JSON objects.');
      }
      return GroupMetadata.fromJson(Map<String, dynamic>.from(group));
    }).toList();
  }
  if (json is Map) {
    final map = Map<String, dynamic>.from(json);
    for (final key in ['groups', 'items', 'data', 'results']) {
      if (map.containsKey(key)) return _parseGroups(map[key]);
    }
  }
  throw const FormatException('Group response must contain a group array.');
}
