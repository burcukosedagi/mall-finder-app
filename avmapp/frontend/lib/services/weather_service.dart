import 'dart:convert';
import 'package:frontend/models/weather.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const currentWeatherUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName, {int dayOffset = 0}) async {
    try {
      print('[WEATHER] Şehir: $cityName | Gün offset: $dayOffset');

      if (dayOffset == 0) {
        final url = '$currentWeatherUrl?q=$cityName&appid=$apiKey&units=metric';
        print('[WEATHER] Current weather API: $url');

        final response = await http.get(Uri.parse(url));

        print('[WEATHER] Status code: ${response.statusCode}');
        print('[WEATHER] Body: ${response.body}');

        if (response.statusCode == 200) {
          return Weather.fromJson(jsonDecode(response.body));
        } else {
          throw Exception('Bugünün hava durumu alınamadı.');
        }
      } else {
        final url = '$forecastUrl?q=$cityName&appid=$apiKey&units=metric';
        print('[WEATHER] Forecast weather API: $url');

        final response = await http.get(Uri.parse(url));
        print('[WEATHER] Status code: ${response.statusCode}');
        print('[WEATHER] Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List forecasts = data['list'];
          final city = data['city']['name'];

          int index = (dayOffset * 8).clamp(0, forecasts.length - 1);
          final forecast = forecasts[index];

          return Weather(
            cityName: city,
            temperature: forecast['main']['temp'].toDouble(),
            mainCondition: forecast['weather'][0]['main'],
          );
        } else {
          throw Exception('Tahmin verisi alınamadı.');
        }
      }
    } catch (e) {
      print('[WEATHER] Hata oluştu: $e');
      rethrow;
    }
  }

  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      print('[LOCATION] İlk izin durumu: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('[LOCATION] Konum izni reddedildi.');
          return "";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[LOCATION] Konum izni kalıcı olarak reddedildi.');
        return "";
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      print('[LOCATION] Pozisyon: ${position.latitude}, ${position.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        print('[LOCATION] Hiç placemark bulunamadı.');
        return "";
      }

      final placemark = placemarks[0];

      print(
        '[LOCATION] Full Placemark: '
        'locality=${placemark.locality}, '
        'subAdmin=${placemark.subAdministrativeArea}, '
        'admin=${placemark.administrativeArea}, '
        'country=${placemark.country}',
      );

      String? city = placemark.locality;
      if (city == null || city.isEmpty) city = placemark.subAdministrativeArea;
      if (city == null || city.isEmpty) city = placemark.administrativeArea;
      if (city == null || city.isEmpty) city = placemark.country;

      print('[LOCATION] Final şehir adı: $city');
      return city ?? "";
    } catch (e) {
      print('[LOCATION] Hata oluştu: $e');
      return "";
    }
  }
}
