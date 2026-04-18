import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class MarketTicker {
  final String symbol;
  final double currentPrice;
  final double priceChangePercent;
  final double highPrice;
  final double lowPrice;
  final double volume;

  MarketTicker({
    required this.symbol,
    required this.currentPrice,
    required this.priceChangePercent,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });

  factory MarketTicker.fromJson(Map<String, dynamic> json) {
    return MarketTicker(
      symbol: json['s'] as String,
      currentPrice: double.parse(json['c']),
      priceChangePercent: double.parse(json['P']),
      highPrice: double.parse(json['h']),
      lowPrice: double.parse(json['l']),
      volume: double.parse(json['v']),
    );
  }
}

class MarketDataApi {
  WebSocketChannel? _channel;
  Timer? _indicesTimer;
  final _tickerController = StreamController<Map<String, MarketTicker>>.broadcast();
  
  final Map<String, MarketTicker> _latestData = {};

  Stream<Map<String, MarketTicker>> get tickerStream => _tickerController.stream;

  void connect() {
    _connectWebSocket();
    _startIndicesPolling();
  }

  void _connectWebSocket() {
    try {
      // Connect to Binance WebSocket for BTC/JPY, ETH/JPY, SOL/JPY
      final wsUrl = Uri.parse(
          'wss://stream.binance.com:9443/ws/btcjpy@ticker/ethjpy@ticker/soljpy@ticker');
      
      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.stream.listen((message) {
        try {
          final data = jsonDecode(message as String);
          if (data['e'] == '24hrTicker') {
            final ticker = MarketTicker.fromJson(data);
            
            // Format symbol to display cleanly (e.g. BTCJPY -> BTC/JPY)
            final cleanSymbol = ticker.symbol.replaceFirst('JPY', '');
            
            _latestData[cleanSymbol] = ticker;
            _emitData();
          }
        } catch (e) {
          // Parse error
        }
      }, onError: (error) {
        // Handle error, try reconnect
        _reconnectWebSocket();
      }, onDone: () {
        // Connection closed manually or dropped, try reconnect
        _reconnectWebSocket();
      });
    } catch (_) {
      _reconnectWebSocket();
    }
  }

  void _startIndicesPolling() {
    _fetchIndices();
    _indicesTimer = Timer.periodic(const Duration(minutes: 5), (_) => _fetchIndices());
  }

  Future<void> _fetchIndices() async {
    final symbols = {
      '^N225': '日経平均',
      '^IXIC': 'NASDAQ',
      '^JPXN400': 'JPX日経400',
      '^DJI': 'NYダウ',
      '^GSPC': 'S&P500',
      '^N300': '日経300',
    };

    for (final entry in symbols.entries) {
      try {
        final uri = Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/${entry.key}?interval=1d&range=1d');
        final response = await http.get(uri, headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
        });
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final result = data['chart']?['result']?[0];
          final meta = result?['meta'];
          
          if (meta != null) {
            double currentPrice = (meta['regularMarketPrice'] ?? 0).toDouble();
            double previousClose = (meta['previousClose'] ?? 0).toDouble();
            double changePercent = 0.0;
            if (previousClose > 0) {
              changePercent = ((currentPrice - previousClose) / previousClose) * 100;
            }
            
            _latestData[entry.value] = MarketTicker(
              symbol: entry.value,
              currentPrice: currentPrice,
              priceChangePercent: changePercent,
              highPrice: currentPrice, // simplified
              lowPrice: currentPrice, // simplified
              volume: 0,
            );
          }
        }
      } catch (_) {
        // Ignore Yahoo fetch errors and continue
      }
    }
    _emitData();
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_tickerController.isClosed) {
        _connectWebSocket();
      }
    });
  }

  void _emitData() {
    if (!_tickerController.isClosed) {
      _tickerController.add(Map.from(_latestData));
    }
  }

  void dispose() {
    _channel?.sink.close();
    _indicesTimer?.cancel();
    _tickerController.close();
  }
}
