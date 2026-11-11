import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/label_models.dart';

/// WhatsApp Business Labels management service.
class LabelService {
  final OpenWaHttpClient _client;

  LabelService(this._client);

  /// Fetches all chat labels.
  Future<ApiResponse<List<Label>>> getAllLabels() async {
    return _client.get<List<Label>>(
      '/labels',
      parser: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((e) => Label.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Gets single label by ID.
  Future<ApiResponse<Label>> getLabelById(String labelId) async {
    return _client.get<Label>(
      '/labels/$labelId',
      parser: (json) => Label.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Creates a new business label.
  Future<ApiResponse<Label>> addLabel(String name, String hexColor) async {
    return _client.post<Label>(
      '/labels/create',
      body: {
        'name': name,
        'hexColor': hexColor,
      },
      parser: (json) => Label.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Deletes a label.
  Future<ApiResponse<bool>> deleteLabel(String labelId) async {
    return _client.delete<bool>(
      '/labels/$labelId',
      parser: (json) => json['deleted'] as bool? ?? true,
    );
  }

  /// Assigns a label to a specific chat.
  Future<ApiResponse<bool>> assignLabelToChat(String chatId, String labelId) async {
    return _client.post<bool>(
      '/labels/assign',
      body: {
        'chatId': chatId,
        'labelId': labelId,
      },
      parser: (json) => json['assigned'] as bool? ?? true,
    );
  }

  /// Removes a label from a chat.
  Future<ApiResponse<bool>> removeLabelFromChat(String chatId, String labelId) async {
    return _client.post<bool>(
      '/labels/unassign',
      body: {
        'chatId': chatId,
        'labelId': labelId,
      },
      parser: (json) => json['unassigned'] as bool? ?? true,
    );
  }
}
