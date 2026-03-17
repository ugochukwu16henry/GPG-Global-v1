import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

class BackendRealtimeService {
  BackendRealtimeService({required this.baseUrl});

  final String baseUrl;
  io.Socket? _socket;
  final _redFlagController = StreamController<String>.broadcast();

  Stream<String> get redFlags => _redFlagController.stream;

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

    _socket?.connect();
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _redFlagController.close();
  }
}
