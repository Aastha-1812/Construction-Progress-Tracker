import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/db_fields.dart';

class WeatherService {
  Stream<Map<String, dynamic>> weatherStream() async* {
    while (true) {
      yield await fetchWeather();
      await Future.delayed(
        Duration(seconds: WeatherFields.updateIntervalSeconds),
      );
    }
  }

  Future<Map<String, dynamic>> fetchWeather() async {
    try {
      final uri = Uri.parse(
        "${WeatherFields.baseUrl}"
            "?q=${WeatherFields.city}"
            "&appid=${WeatherFields.apiKey}"
            "&units=${WeatherFields.units}",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return {
        "error": "API error: ${response.statusCode}",
        "message": response.body
      };

    } catch (e) {
      return {
        "error": "Exception occurred",
        "message": e.toString(),
      };
    }
  }
}
