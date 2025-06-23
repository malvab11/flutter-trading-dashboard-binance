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

  final ValueNotifier<bool> connectionStatus = ValueNotifier(false);

  BinanceWebSocketService(this._initialStreams) {
    _connect();
  }

  Stream<Map<String, dynamic>> get stream => _controller.stream;
  Map<String, Map<String, dynamic>> get lastData => _cache;

  void _connect() {
    final url =
        'wss://stream.binance.com:9443/stream?streams=${_initialStreams.join('/')}';
    debugPrint('🔌 Conectando a $url');

    _channel = WebSocketChannel.connect(Uri.parse(url));
    _isConnected = true;
    _shouldReconnect = true;
    connectionStatus.value = true;

    _channel.stream.listen(
      (event) {
        final decoded = jsonDecode(event);
        final streamType = decoded['stream']?.toString() ?? '';
        final data = decoded['data'];

        debugPrint('📥 Mensaje recibido [$streamType]');

        if (streamType.contains('@ticker')) {
          _handleTicker(data);
        } else if (streamType.contains('@miniTicker')) {
          _handleMiniTicker(data);
        } else if (streamType.contains('@depth')) {
          _handleOrderBook(data);
        } else {
          debugPrint('❓ Stream no reconocido: $streamType');
        }
      },
      onError: (error) {
        debugPrint('❌ WebSocket error: $error');
        _scheduleReconnect();
      },
      onDone: () {
        debugPrint('🔌 WebSocket cerrado');
        _scheduleReconnect();
      },
    );
  }

  void _handleTicker(Map<String, dynamic> data) {
    final symbol = data['s']?.toString().toLowerCase();
    if (symbol != null && data.containsKey('c')) {
      _cache[symbol] = data;
      debugPrint('🔄 Actualizado ticker: ${symbol.toUpperCase()}');
      _emitThrottled(data);
    }
  }

  void _handleMiniTicker(Map<String, dynamic> data) {
    final symbol = data['s']?.toString().toLowerCase();
    if (symbol != null && data.containsKey('c')) {
      _cache['${symbol}_mini'] = data;
      _emitThrottled(data);
    }
  }

  void _handleOrderBook(Map<String, dynamic> data) {
    final symbol = data['s']?.toString().toLowerCase() ?? 'unknown';

    // Adaptamos el formato al esperado por el modelo (bids/asks)
    final adaptedData = {
      'symbol': symbol.toUpperCase(),
      'bids': data['b'] ?? [],
      'asks': data['a'] ?? [],
    };

    // Validación
    if (adaptedData['bids'] != null && adaptedData['asks'] != null) {
      final streamKey = '${symbol}_depth';
      _cache[streamKey] = adaptedData;
      debugPrint('📊 OrderBook adaptado para $symbol');
      _controller.add(adaptedData);
    } else {
      debugPrint('⚠️ OrderBook inválido (sin bids/asks): $data');
    }
  }

  void _emitThrottled(Map<String, dynamic> data) {
    final now = DateTime.now();
    if (now.difference(_lastEmit).inMilliseconds > 300) {
      _lastEmit = now;
      _controller.add(data);
      debugPrint('🟡 Emitiendo datos al stream: ${data['s'] ?? "sin símbolo"}');
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    _isConnected = false;
    connectionStatus.value = false;

    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      debugPrint('🔁 Reintentando conexión...');
      _connect();
    });
  }

  void subscribeToStreams(List<String> streams) {
    if (!_isConnected) {
      debugPrint('🚫 No conectado al WebSocket, no se puede suscribir.');
      return;
    }
    final payload = {
      "method": "SUBSCRIBE",
      "params": streams,
      "id": _messageId++,
    };
    debugPrint('📨 Enviando SUBSCRIBE: $payload');
    _channel.sink.add(jsonEncode(payload));
  }

  void unsubscribeFromStreams(List<String> streams) {
    if (!_isConnected) {
      debugPrint('🚫 No conectado al WebSocket, no se puede desuscribir.');
      return;
    }
    final payload = {
      "method": "UNSUBSCRIBE",
      "params": streams,
      "id": _messageId++,
    };
    debugPrint('📤 Enviando UNSUBSCRIBE: $payload');
    _channel.sink.add(jsonEncode(payload));
  }

  void reconnect() {
    _shouldReconnect = true;
    close();
    _connect();
  }

  void close() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    if (!_controller.isClosed) _controller.close();
    _isConnected = false;
    connectionStatus.value = false;
    _channel.sink.close();
  }
}
