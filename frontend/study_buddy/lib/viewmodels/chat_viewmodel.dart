import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../data/dummy_data.dart';

class ChatViewModel extends ChangeNotifier {
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMessages(String sessionId,
      {String? myUserId, String? myName}) async {
    _isLoading = true;
    _messages = [];
    notifyListeners();

    if (sessionId.startsWith('dummy-')) {
      await Future.delayed(const Duration(milliseconds: 500));
      _messages = DummyData.messagesForSession(
          sessionId, myUserId ?? 'me', myName ?? 'You');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final data = await ApiService.getMessages(sessionId);
      _messages = data.map((m) => MessageModel.fromJson(m)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load messages';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(
      {required String sessionId, required String content}) async {
    if (sessionId.startsWith('dummy-')) {
      final dummyMsg = MessageModel(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        senderId: 'me',
        senderName: 'You',
        content: content,
        sentAt: DateTime.now().toIso8601String(),
      );
      _messages.add(dummyMsg);
      notifyListeners();
      return;
    }

    try {
      final data =
          await ApiService.sendMessage(sessionId: sessionId, content: content);
      _messages.add(MessageModel.fromJson(data));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message';
      notifyListeners();
    }
  }
}
