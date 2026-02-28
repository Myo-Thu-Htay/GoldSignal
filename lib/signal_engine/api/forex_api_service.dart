import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/trading_constants.dart';
import '../model/candle.dart';
import '../model/timeframe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForexApiService {
  final Dio _dio = Dio();
  final String apiKey = dotenv.env['FINAGE_API'] ?? 'default_key';

  Future<List<Candle>> fetchCandles(Timeframe tf) async {
    try {
      final response = await _dio.get(
        TradingConstants.finageApiUrl,
        queryParameters: {
          'symbol': TradingConstants.symbol,
          'multiply': tf.apiValue,
          'time': tf.displayName,
          "from": '2025-01-01',
          "to": DateTime.timestamp().toString(),
          "apikey": apiKey, // Use the API key from the environment variable
        },
      );
      if (response.statusCode == 200) {
        final values = response.data['results'];
        double toDouble(dynamic value) {
          if (value == null) return 0.0;
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          return 0.0;
        }
        List<Candle> candles = values.map<Candle>((jason) {
          return Candle(
            open: toDouble(jason['o']),
            high: toDouble(jason['h']),
            low: toDouble(jason['l']),
            close: toDouble(jason['c']),
            time: DateTime.fromMillisecondsSinceEpoch(toDouble(jason['t'])
                .toInt()), // Ensure time is parsed correctly
            volume: toDouble(jason['v'] ?? 0), // Handle volume parsing
          );
        }).toList();
        //candles = candles.toList(); // Reverse to have oldest first
        if (kDebugMode) {
          print('First Candle ${candles.first.time}');
          print('Last Candle ${candles.last.time}');
          print('Parsed ${candles.length} candles successfully.');
        }
        return candles;
      } else {
        throw Exception('Failed to load candles');
      }
    } catch (e) {
      throw Exception('Error fetching candles: $e');
    }
  }
}
