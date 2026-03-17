import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

class BackendRealtimeService {
  BackendRealtimeService({required this.baseUrl});

  final String baseUrl;
  io.Socket? _socket;
  final _redFlagController = StreamController<String>.broadcast();
  final _typingController = StreamController<String>.broadcast();
  final _readReceiptController = StreamController<String>.broadcast();
  final _actionRequiredController = StreamController<String>.broadcast();

  Stream<String> get redFlags => _redFlagController.stream;
  Stream<String> get typingIndicators => _typingController.stream;
  Stream<String> get readReceipts => _readReceiptController.stream;
  Stream<String> get actionRequired => _actionRequiredController.stream;

  void connect() {
    _socket?.dispose();
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket?.on('control-room:red-flag', (payload) {
      if (payload is Map) {
        final severity = payload['severity']?.toString() ?? 'LOW';
        final reason = payload['reason']?.toString() ?? 'Violation detected';
        _redFlagController.add('$severity red flag: $reason');
      }
    });

    _socket?.on('chat:typing', (payload) {
      if (payload is Map) {
        final userId = payload['userId']?.toString() ?? 'unknown';
        final isTyping = payload['isTyping'] == true;
        _typingController.add('$userId ${isTyping ? 'is typing...' : 'stopped typing'}');
      }
    });

    _socket?.on('chat:read', (payload) {
      if (payload is Map) {
        final userId = payload['userId']?.toString() ?? 'unknown';
        final messageId = payload['messageId']?.toString() ?? '';
        _readReceiptController.add('$userId read message $messageId');
      }
    });

    _socket?.on('admin:action-required', (payload) {
      if (payload is Map) {
        final roomId = payload['roomId']?.toString() ?? 'unknown-room';
        _actionRequiredController.add('Action required for room $roomId');
      }
    });

    _socket?.connect();
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _redFlagController.close();
    _typingController.close();
    _readReceiptController.close();
    _actionRequiredController.close();
  }

  void joinRoom(String roomId) {
    _socket?.emit('room:join', roomId);
  }

  void sendTyping({required String roomId, required String userId, required bool isTyping}) {
    _socket?.emit('chat:typing', {
      'roomId': roomId,
      'userId': userId,
      'isTyping': isTyping,
    });
  }

  void markRead({required String roomId, required String messageId, required String userId}) {
    _socket?.emit('chat:read', {
      'roomId': roomId,
      'messageId': messageId,
      'userId': userId,
    });
  }
}
