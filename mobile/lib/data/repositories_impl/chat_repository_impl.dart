import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_paths.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._api);
  final ApiClient _api;

  @override
  Future<List<ConversationEntity>> list({String? projectId}) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        ApiPaths.conversations,
        query: projectId != null ? {'project_id': projectId} : null,
      );
      final raw = (res.data?['conversations'] as List?) ?? const [];
      return raw
          .map((e) => ConversationEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ConversationEntity> create({
    required String projectId,
    required String provider,
    required String model,
    String? title,
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(ApiPaths.conversations, body: {
        'project_id': projectId,
        'provider': provider,
        'model': model,
        if (title != null) 'title': title,
      });
      return ConversationEntity.fromJson(res.data ?? const {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _api.delete<Map<String, dynamic>>(ApiPaths.conversation(id));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> rename(String id, String title) async {
    try {
      await _api.patch<Map<String, dynamic>>(ApiPaths.conversation(id), body: {'title': title});
    } catch (e) {
      throw mapError(e);
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(apiClientProvider));
});
