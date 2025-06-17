import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BinanceWebSocketService {
  final List<String> _initialStreams;
  late WebSocketChannel _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  final _cache = <String, Map<String, dynamic>>{};
  Timer? _reconnectTimer;
  int _messageId = 1;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  DateTime _lastEmit = DateTime.now();

  /// Estado de conexión: true si conectado, false si desconectado
  final ValueNotifier<bool> connectionStatus = ValueNotifier(false);

  BinanceWebSocketService(this._initialStreams) {
    _connect();
  }

  /// Exponer el stream para la UI o los providers
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  /// Últimos datos cacheados por tipo de stream
  Map<String, Map<String, dynamic>> get lastData => _cache;

  void _connect() {
    final url =
        'wss://stream.binance.com:9443/stream?streams=${_initialStreams.join('/')}';
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _isConnected = true;
    _shouldReconnect = true;
    connectionStatus.value = true;

    _channel.stream.listen(
      (event) {
        final decoded = jsonDecode(event);
        final streamType = decoded['stream']?.toString() ?? '';
        final data = decoded['data'];

        if (streamType.contains('@ticker')) {
          _handleTicker(data);
        } else if (streamType.contains('@miniTicker')) {
          _handleMiniTicker(data);
        } else if (streamType.contains('@depth')) {
          _handleOrderBook(data);
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _scheduleReconnect();
      },
      onDone: () {
        print('WebSocket closed');
        _scheduleReconnect();
      },
    );
  }

  void _handleTicker(Map<String, dynamic> data) {
    if (data.containsKey('s') &&
        data.containsKey('c') &&
        data.containsKey('P')) {
      final streamKey = data['s'].toString().toLowerCase();
      _cache[streamKey] = data;
      _emitThrottled(data);
    }
  }

  void _handleMiniTicker(Map<String, dynamic> data) {
    if (data.containsKey('s') && data.containsKey('c')) {
      final streamKey = '${data['s'].toString().toLowerCase()}_mini';
      _cache[streamKey] = data;
      _emitThrottled(data);
    }
  }

  void _handleOrderBook(Map<String, dynamic> data) {
    if (data.containsKey('bids') && data.containsKey('asks')) {
      final streamKey =
          '${data['s']?.toString().toLowerCase() ?? 'depth'}_depth';
      _cache[streamKey] = data;
      _emitThrottled(data);
    }
  }

  void _emitThrottled(Map<String, dynamic> data) {
    final now = DateTime.now();
    if (now.difference(_lastEmit).inMilliseconds > 300) {
      _lastEmit = now;
      _controller.add(data);
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    _isConnected = false;
    connectionStatus.value = false;

    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      print('Intentando reconectar...');
      _connect();
    });
  }

  void subscribeToStreams(List<String> streams) {
    if (!_isConnected) return;
    final payload = {
      "method": "SUBSCRIBE",
      "params": streams,
      "id": _messageId++,
    };
    _channel.sink.add(jsonEncode(payload));
  }

  void unsubscribeFromStreams(List<String> streams) {
    if (!_isConnected) return;
    final payload = {
      "method": "UNSUBSCRIBE",
      "params": streams,
      "id": _messageId++,
    };
    _channel.sink.add(jsonEncode(payload));
  }

  void close() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _controller.close();
    _isConnected = false;
    connectionStatus.value = false;
    _channel.sink.close();
  }
}
