import '../entities/conversation.dart';

abstract class ChatRepository {
  Future<List<ConversationEntity>> list({String? projectId});
  Future<ConversationEntity> create({
    required String projectId,
    required String provider,
    required String model,
    String? title,
  });
  Future<void> delete(String id);
  Future<void> rename(String id, String title);
}
